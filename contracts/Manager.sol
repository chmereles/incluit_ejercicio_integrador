// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./Ticket.sol";

contract MyERC721Token is ERC721 {
    constructor() ERC721("MyERC721Token", "MTK") {}

    function mint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId, "");
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(
            _isApprovedOrOwner(from, tokenId),
            "MyERC721Token:::: caller is not token owner or approved"
        );

        _transfer(from, to, tokenId);
    }
}

contract Manager {
    uint256 ticketId;
    MyERC721Token private ticketERC721;
    Ticket[] private tickets;
    uint256 private ticketPriceTax;
    address private admin;

    event TicketCreated(address ticketOwner);

    modifier onlyOwnerOrAdmin(address ticketAddr) {
        require(
            msg.sender == admin || msg.sender == ticketAddr,
            "Manager: Only the owner or admin of the Manager contract are allowed"
        );
        _;
    }

    constructor() {
        admin = msg.sender;

        ticketPriceTax = 5;
        ticketERC721 = new MyERC721Token();
    }

    receive() external payable {}

    function createTicket(
        string memory ticketName,
        uint256 date,
        string memory eventDescription,
        EventType eventType,
        TicketStatus status,
        TransferStatus transferStatus
    ) public {
        address _owner = msg.sender;
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
    }

    function showAllTickets() public view returns (Ticket[] memory) {
        return tickets;
    }

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

    function transferTicket(Ticket _ticket, address _newOwner)
        public
        onlyOwnerOrAdmin(_ticket.getOwner())
    {
        require(
            _ticket.getTransferStatus() == TransferStatus.TRANSFERIBLE,
            "Manager: El ticket no es transferible"
        );
        ticketERC721.transferFrom(
            _ticket.getOwner(),
            _newOwner,
            _ticket.getId()
        );
        _ticket.changeOwner(_newOwner);
    }

    function changeTicketPrice(Ticket _ticket)
        public
        payable
        onlyOwnerOrAdmin(_ticket.getOwner())
    {
        uint256 newPrice = msg.value;
        address payable ticketAddr = payable(address(_ticket));

        uint256 commission = (newPrice * ticketPriceTax) / 100;
        (bool success, ) = ticketAddr.call{value: newPrice - commission}("");
        require(success);

        _ticket.changePrice(newPrice);
    }

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

    function showStatistics() public view returns (uint256, uint256) {
        uint256 totalPrice;
        for (uint256 i = 0; i < tickets.length; i++) {
            totalPrice += tickets[i].getPrice();
        }

        return (tickets.length, totalPrice);
    }

    function removeTicket(uint256 index) public {
        if (index >= tickets.length) return;

        Ticket _ticket = tickets[index];

        tickets[index] = tickets[tickets.length - 1];
        tickets.pop();

        ticketERC721.transferFrom(
            _ticket.getOwner(),
            address(this),
            _ticket.getId()
        );
    }

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
}
