// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./Ticket.sol";
import "./MyERC721Token.sol";

contract Manager {
    // Autoincrement state to usse as token id
    uint256 ticketId;

    // Tax for ticket price change
    uint256 private ticketPriceTax;

    // Admin manager
    address private admin;

    // List fo tickets
    Ticket[] private tickets;

    // Custom ticket ERC721 contract
    MyERC721Token private ticketERC721;

    event TransferredTicket(address oldOwner, address newOwner);
    event TicketCreated(Ticket ticket);
    event TicketRemoved(Ticket ticket);
    event TicketPriceChanged(Ticket ticket, uint256 newPrice);

    /**
     * @dev Modifier.
     */
    modifier onlyOwnerOrAdmin(address ticketOwner) {
        require(
            msg.sender == admin || msg.sender == ticketOwner,
            "Manager: Only the owner or admin of the Manager contract are allowed"
        );
        _;
    }

    /**
     * @dev Modifier.
     */
    modifier onlyOwner(address ticketOwner) {
        require(
            msg.sender == ticketOwner,
            "Manager: Only the owner are allowed"
        );
        _;
    }

    /**
     * @dev Initializes the contract by setting a `admin`, `ticketTax` and `ticketERC721`.
     */
    constructor() {
        admin = msg.sender;

        ticketPriceTax = 5;
        ticketERC721 = new MyERC721Token();
    }

    receive() external payable {}

    fallback() external payable {}

    /**
     * @dev Crete a new ticket mints `ticket id` and add the ticket to tickets list
     *
     * Emits a {TicketCreated} event.
     */
    function createTicket(
        string memory ticketName,
        uint256 date,
        string memory eventDescription,
        EventType eventType,
        TicketStatus status,
        TransferStatus transferStatus
    ) public {
        address _owner = msg.sender;
        // Always increments, hence a unique value is obtained
        ticketId += 1;

        Ticket _ticket = new Ticket(
            ticketId,
            ticketName,
            date,
            eventDescription,
            eventType,
            status,
            transferStatus,
            _owner
        );

        ticketERC721.mint(_owner, _ticket.getId());
        tickets.push(_ticket);

        emit TicketCreated(_ticket);
    }

    /**
     * @dev Show all the tickets that the platform contains, regardless of who owns them
     *
     * @return Ticket[] whether the call correctly returned the list of ticket
     */
    function showAllTickets() public view returns (Ticket[] memory) {
        return tickets;
    }

    /**
     * @dev Show tickets that are assigned to a particular owner
     *
     * @return Ticket[] whether the call correctly returned the list of ticket
     */
    function showTicketsByAddress(address addr)
        public
        view
        returns (Ticket[] memory)
    {
        uint256 count;
        for (uint256 i = 0; i < tickets.length; i++) {
            if (tickets[i].getOwner() == addr) {
                count++;
            }
        }

        Ticket[] memory result = new Ticket[](count);
        uint256 j = 0;
        for (uint256 i = 0; i < tickets.length; i++) {
            if (tickets[i].getOwner() == addr) {
                result[j++] = tickets[i];
                if (j == count) {
                    break;
                }
            }
        }
        return result;
    }

    /**
     * @dev Transfer a ticket according to its status, if a Ticket has a Transferable status, it can change owners
     *
     * @param _ticket Ticket to transfer
     * @param _newOwner New ticket owner
     * 
     * Emits a {TransferredTicket} event.
     */
    function transferTicket(Ticket _ticket, address _newOwner)
        public
        onlyOwnerOrAdmin(_ticket.getOwner())
    {
        address oldOwner;
        require(
            _ticket.getTransferStatus() == TransferStatus.TRANSFERIBLE,
            "Manager: El ticket no es transferible"
        );

        oldOwner = _ticket.getOwner();
        ticketERC721.transferFrom(oldOwner, _newOwner, _ticket.getId());
        _ticket.changeOwner(_newOwner);

        emit TransferredTicket(oldOwner, _newOwner);
    }

    /**
     * @dev Allow the owner of a ticket to change the price of the ticket, but in that 
     * case the Manager contract charges a 5% commission and remains in their balance
     *
     * @param _ticket A ticket
     */
    function changeTicketPrice(Ticket _ticket)
        public
        payable
        onlyOwner(_ticket.getOwner())
    {
        uint256 newPrice = msg.value;
        address payable ticketAddr = payable(address(_ticket));

        uint256 commission = (newPrice * ticketPriceTax) / 100;
        (bool success, ) = ticketAddr.call{value: newPrice - commission}("");
        require(success);

        _ticket.changePrice(newPrice);

        emit TicketPriceChanged(_ticket, newPrice);
    }

    /**
     * @dev Show ticket information
     *
     * @param _ticket A ticket
     */
    function showTicketInformation(Ticket _ticket)
        public
        view
        returns (
            uint256,
            string memory,
            uint256,
            uint256,
            string memory,
            EventType,
            TicketStatus,
            address
        )
    {
        return _ticket.showInformation();
    }

    /**
     * @dev Show the number of tickets that the platform has and the total price of the tickets
     *
     */
    function showStatistics() public view returns (uint256, uint256) {
        uint256 totalPrice;
        for (uint256 i = 0; i < tickets.length; i++) {
            totalPrice += tickets[i].getPrice();
        }

        return (tickets.length, totalPrice);
    }

    /**
     * @dev Remove a ticket from the list by index and transfer the token to the contract address
     *
     * Emits a {TicketRemoved} event.
     */
    function removeTicket(uint256 index) public {
        require(index < tickets.length, "the ticket does not exist");
        
        Ticket _ticket = tickets[index];

        tickets[index] = tickets[tickets.length - 1];
        tickets.pop();

        ticketERC721.transferFrom(
            _ticket.getOwner(),
            address(this),
            _ticket.getId()
        );

        emit TicketRemoved(_ticket);
    }

    /**
     * @dev Returns the owner of the `ticket`.
     *
     * @return ticket owner address
     */
    function ownerOf(Ticket ticket) public view returns (address) {
        address owner = ticket.getOwner();
        address owner721 = ticketERC721.ownerOf(ticket.getId());
        require(owner == owner721, "Manager: Owners are different");
        return owner;
    }

    function getTickets() public view returns (Ticket[] memory) {
        return tickets;
    }

    function getTicketPrice(Ticket ticket) public view returns (uint256) {
        return ticket.getPrice();
    }

    function changeTicketTranserStatus(
        Ticket _ticket,
        TransferStatus _transferStatus
    ) public {
        _ticket.changeTranserStatus(_transferStatus);
    }
}
