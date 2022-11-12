// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract MyERC721Token is ERC721 {
    constructor() ERC721("MyERC721Token", "MTK") {}

    function mint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId, "");
    }
}

import "./Ticket.sol";

contract Manager {
    event TicketCreated(address ticketOwner);

    MyERC721Token private s_NFTs;
    Ticket[] private tickets;
    uint256 private ticketPriceTax;
    mapping(address => Ticket[]) private ownerTickets;

    constructor() {
        ticketPriceTax = 5;
        // MyERC721Token myToken = new MyERC721Token();

        s_NFTs = new MyERC721Token();
    }

    receive() external payable {}

    function createTicket() public {
        string memory ticketName = "ticket1";
        uint256 date = block.timestamp;
        string memory eventDescription = "description";
        EventType eventType;
        TicketStatus status;
        TransferStatus transferStatus;

        address _owner = msg.sender;

        Ticket _ticket = new Ticket(
            ticketName,
            date,
            eventDescription,
            eventType,
            status,
            transferStatus,
            _owner
        );

        s_NFTs.mint(msg.sender, _ticket.getId());

        tickets.push(_ticket);
        ownerTickets[_owner].push(_ticket);

        emit TicketCreated(_ticket.getOwner());
    }

    function showAllTickets() public view returns (Ticket[] memory) {
        return tickets;
    }

    function showTicketsByAddress(address addr)
        public
        view
        returns (Ticket[] memory)
    {
        return ownerTickets[addr];
    }

    function transferTicket(Ticket _ticket, address _newOwner) public {
        require(
            _ticket.getTransferStatus() == TransferStatus.TRANSFERIBLE,
            "Manager: El ticket no es transferible"
        );
        s_NFTs.transferFrom(_ticket.getOwner(), _newOwner, _ticket.getId());

        _ticket.changeOwner(_newOwner);
    }

    function changeTicketPrice(Ticket _ticket) public payable {
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

    // function showStatistics() public view returns (uint256, uint256) {
    //     uint256 totalPrice;
    //     for (uint256 i = 0; i < tickets.length; i++) {
    //         totalPrice += tickets[i].getPrice();
    //     }

    //     return (tickets.length, totalPrice);
    // }

    // function getTicketBalance(Ticket _ticket) public view returns (uint256) {
    //     return address(_ticket).balance;
    // }

    // function payTicket(Ticket _ticket, uint256 amount) public payable {
    //     (bool sent, ) = address(_ticket).call{value: amount}("");
    //     require(sent, "Failed to send Ether");
    // }
}
