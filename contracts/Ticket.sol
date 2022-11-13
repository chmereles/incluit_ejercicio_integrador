// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

enum TransferStatus {
    TRANSFERIBLE,
    NO_TRANSFERIBLE
}

enum EventType {
    SPORTS,
    MUSIC,
    CINEMA
}

enum TicketStatus {
    VALID,
    USED,
    EXPIRED
}

contract Ticket {
    uint256 private id;
    string private eventName;
    uint256 private eventDate;
    string private eventDescription;
    EventType private eventType;
    uint256 private price;
    TicketStatus private status;
    TransferStatus private transferStatus;
    address private owner;

    receive() external payable {}

    constructor(
        uint _id,
        string memory _eventName,
        uint256 _eventDate,
        string memory _eventDescription,
        EventType _eventType,
        TicketStatus _status,
        TransferStatus _transferStatus,
        address _owner
    )  {
        eventName = _eventName;
        eventDate = _eventDate;
        eventDescription = _eventDescription;
        eventType = _eventType;
        status = _status;
        transferStatus = _transferStatus;
        owner = _owner;
        id = generateId(_id);
    }

    function changePrice(uint256 _newPrice) public {
        price = _newPrice;
    }

    function changeTranserStatus(TransferStatus _transferStatus) public {
        transferStatus = _transferStatus;
    }

    function changeStatus(TicketStatus _status) public {
        status = _status;
    }

    function changeOwner(address _newOwner) public {
        owner = _newOwner;
    }

    function showInformation()
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
        return (
            id,
            eventName,
            eventDate,
            price,
            eventDescription,
            eventType,
            status,
            owner
        );
    }

    function getStatus() public view returns (TicketStatus) {
        return status;
    }

    function getTransferStatus() public view returns (TransferStatus) {
        return transferStatus;
    }

    function generateId(uint _id) private pure returns(uint) {
        return uint256(keccak256(abi.encodePacked(_id)));
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function getPrice() public view returns (uint256) {
        return price;
    }

    function getId() public view returns (uint256) {
        return id;
    }
}
