// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./Ticket.sol";

contract Manager {
    event TicketCreated(address ticketOwner);

    Ticket[] private tickets;
    uint256 private ticketPriceTax;

    constructor() {
        ticketPriceTax = 5;
    }

    receive() external payable {}

    // fallback()external payable {}

    function createTicket() public {
        string memory ticketName = "ticket1";
        uint256 date = block.timestamp;
        string memory eventDescription = "description";
        EventType eventType;
        TicketStatus status;
        TransferStatus transferStatus;

        Ticket _ticket = new Ticket(
            ticketName,
            date,
            eventDescription,
            eventType,
            status,
            transferStatus,
            msg.sender
        );
        tickets.push(_ticket);
        emit TicketCreated(_ticket.getOwner());
    }

    function showAllTickets() public view returns (Ticket[] memory) {
        return tickets;
    }

    function transferTicket(Ticket _ticket, address _newOwner) public {
        require(
            _ticket.getTransferStatus() == TransferStatus.TRANSFERIBLE,
            "El ticket no es transferible"
        );
        _ticket.changeOwner(_newOwner);
    }

    function changeTicketPrice(Ticket _ticket) public payable {
        uint256 newPrice = msg.value;
        uint256 commission = (newPrice * ticketPriceTax) / 100;
        (bool success, ) = payable(address(_ticket)).call{
            value: newPrice - commission
        }("");
        require(success);

        _ticket.changePrice(newPrice);
    }

    function showTicketInformation(Ticket _ticket)
        public
        view
        returns (
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

    function showTicketsByAddress(address addr)
        public
        view
        returns (
            string memory,
            uint256,
            uint256,
            string memory,
            EventType,
            TicketStatus,
            address
        )
    {
        Ticket _ticket;
        for (uint256 i = 0; i < tickets.length; i++) {
            if (tickets[i].getOwner() == addr) {
                _ticket = tickets[i];
                break;
            }
        }
        return _ticket.showInformation();
    }

    function showStatistics() public view returns (uint256, uint256) {
        uint256 totalPrice;
        for (uint256 i = 0; i < tickets.length; i++) {
            totalPrice += tickets[i].getPrice();
        }

        return (tickets.length, totalPrice);
    }

    function getTicketBalance(Ticket _ticket) public view returns (uint256) {
        return address(_ticket).balance;
    }

    function payTicket(Ticket _ticket, uint256 amount) public payable {
        (bool sent, ) = address(_ticket).call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
}
