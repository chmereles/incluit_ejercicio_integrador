const Manager = artifacts.require("Manager");
const Ticket = artifacts.require("Ticket");
const utils = require("./helpers/utils");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("manager", function (accounts) {
  let manager;
  let [admin, bob, otherAccount] = accounts;
  const TransferStatus = {
    TRANSFERIBLE: 0,
    NO_TRANSFERIBLE: 1,
  };
  const EventType = {
    SPORTS: 0,
    MUSIC: 1,
    CINEMA: 2,
  };
  const TicketStatus = {
    VALID: 0,
    USED: 1,
    EXPIRED: 2,
  };

  // Funcion auxilar
  // Crea un ticket, y devuelve el ticket creado
  async function createTicket({
    from = admin,
    eventName = 'Ticket name 1',
    date = 1,
    eventDescription = 'Description 1',
    eventType = EventType.SPORTS,
    status = TicketStatus.VALID,
    transferStatus = TransferStatus.TRANSFERIBLE
  }) {
    await manager.createTicket(
      eventName,
      date,
      eventDescription,
      eventType,
      status,
      transferStatus, { from: from });

    // let tickets = await manager.getTickets();
    // let firsTicket = await Ticket.at(tickets[0]);
    // let price = await firsTicket.getPrice();
    // console.log(price);

    return (await manager.getTickets())[0];
  }

  beforeEach(async () => {
    manager = await Manager.new();
  })

  it("should assert true", async function () {
    await Manager.deployed();
    return assert.isTrue(true);
  });

  context("function: createTicket", function () {
    it("Should add the ticket", async function () {
      let aTicket = await createTicket({ from: bob });

      let tickets = await manager.getTickets();
      let owner = await manager.ownerOf(aTicket);

      assert.equal(1, tickets.length, "The length of the list should be one (1)");
      assert.equal(bob, owner, "The ticket owner should be the sender");
    })
  });

  context("function: showAllTickets", function () {
    it("should not show any ticket, when no ticket is created", async function () {
      let tickets = await manager.getTickets();

      assert.equal(0, tickets.length, "the length of the list should be zero (0)");
    })

    it("Should show all tickets", async function () {
      await createTicket({ from: admin });
      let tickets = await manager.getTickets();

      assert.equal(1, tickets.length, "The length of the list should be one (1)");
    })
  });

  context("function: showTicketsByAddress", function () {
    it("Should show the tickets that are assigned to an address", async function () {
      await createTicket({ from: admin });
      await createTicket({ from: admin });
      await createTicket({ from: bob });
      let tickets = await manager.showTicketsByAddress(bob);

      assert.equal(1, tickets.length, "the length of the list should be one (1)");
    })

    it("Should not show any ticket, with an address that is not loaded", async function () {
      let tickets = await manager.showTicketsByAddress(bob);

      assert.equal(0, tickets.length, "The length of the list should be zero (0)");
    })
  });

  context("function: transferTicket", function () {
    it("The owner, should change the owner of the ticket", async function () {
      let owner = bob;
      let newOwner = otherAccount;

      let aTicket = await createTicket({ from: owner });

      await manager.transferTicket(aTicket, newOwner, { from: owner });
      let ticketOwner = await manager.ownerOf(aTicket);

      assert.equal(ticketOwner, newOwner, "Only the owner should transfer tickets");
    })

    it("The admin, should change the owner of the ticket", async function () {
      let owner = bob;
      let newOwner = otherAccount;

      let aTicket = await createTicket({ from: owner });

      await manager.transferTicket(aTicket, newOwner, { from: admin });
      let newOwnerTicket = await manager.ownerOf(aTicket);

      assert.equal(newOwnerTicket, newOwner, "Only the owner should transfer tickets");
    })

    it("Should revert the transaction if another user than owner/admin tries to transfer the ticket", async function () {
      let owner = admin;
      let newOwner = bob;
      let notOwnerAdmin = otherAccount;

      let aTicket = await createTicket({ from: owner });

      await utils.shouldThrow(
        manager.transferTicket(aTicket, newOwner, { from: notOwnerAdmin })
      )
      assert(true);
    })

    it("Should revert the transaction it the ticket is no transferible", async function () {
      let owner = admin;
      let newOwner = bob;

      let aTicket = await createTicket({ from: owner, transferStatus: TransferStatus.NO_TRANSFERIBLE });

      await utils.shouldThrow(
        manager.transferTicket(aTicket, newOwner, { from: owner })
      )
      assert(true);
    })
  });

  context("function: changeTicketPrice", function () {
    it("The owner, should change the price of the ticket", async function () {
      let owner = bob;
      let newPrice = 100;

      let aTicket = await createTicket({ from: owner });

      await manager.changeTicketPrice(aTicket, { from: owner, value: newPrice });
      assert(true);

      let updatedPrice = await manager.getTicketPrice(aTicket);
      assert.equal(updatedPrice, newPrice);
    })

    it("Should revert the transaction if another user than owner tries to change ticket's price", async function () {
      let owner = bob;
      let notOwner = admin;

      let aTicket = await createTicket({ from: owner });

      await utils.shouldThrow(
        manager.changeTicketPrice(aTicket, { from: notOwner, value: 100 })
      );
      assert(true);
    })

    it("Should pay a commssion when change the price of the ticket", async function () {
      let owner = admin;
      let commission = 5;
      let newPrice = 100;

      let aTicket = await createTicket({ from: owner });

      await manager.changeTicketPrice(aTicket, { from: owner, value: newPrice });
      let balance = await web3.eth.getBalance(manager.address)

      assert.equal(balance, newPrice * commission / 100);
    })
  });

  context("function: showTicketInformation", function () {
    it("Should show Ticket information", async function () {
      let ticketOwner = admin;
      let eventName = 'My event';

      let aTicket = await createTicket({ eventName: eventName, from: ticketOwner });
      let info = await manager.showTicketInformation(aTicket);

      assert.equal(info[1], eventName);
      assert.equal(info[7], ticketOwner);
    })
  });

  context("function: showStatistics", function () {
    it("Should show Ticket information, total 0 price 0", async function () {
      let info = await manager.showStatistics();
      let ticketCount = info[0]['words'][0];
      let totalPrice = info[1]['words'][0];

      assert.equal(ticketCount, 0);
      assert.equal(totalPrice, 0);
    })

    it("Should show Ticket information to any user", async function () {
      let anyUser = bob;
      let priceTicket1 = 5;
      let priceTicket2 = 6;

      await createTicket({ from: admin });
      await createTicket({ from: anyUser });

      let adminTicket = (await manager.getTickets())[0];
      let otherTicket = (await manager.getTickets())[1];

      await manager.changeTicketPrice(adminTicket, { from: admin, value: priceTicket1 });
      await manager.changeTicketPrice(otherTicket, { from: anyUser, value: priceTicket2 });

      let info = await manager.showStatistics();
      let ticketCount = info[0]['words'][0];
      let totalPrice = info[1]['words'][0];

      assert.equal(ticketCount, 2);
      assert.equal(totalPrice, priceTicket1 + priceTicket2);
    })
  });

  context("function: removeTicket", function () {
    it("Should remove a ticket by index", async function () {
      await createTicket({ from: admin });
      await manager.removeTicket(0);

      let tickets = await manager.getTickets();

      assert.equal(tickets.length, 0);
    })

    it("Should revert if the ticket does not exist", async function () {
      await createTicket({ from: admin });

      await utils.shouldThrow(
        manager.removeTicket(1)
      );
      assert(true);
    })
  });
});
