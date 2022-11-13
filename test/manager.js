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

  beforeEach(async () => {
    manager = await Manager.new();
  })

  it("should assert true", async function () {
    await Manager.deployed();
    return assert.isTrue(true);
  });

  context("function: createTicket", function () {
    it("Should add the ticket", async function () {
      await manager.createTicket({ from: bob });
      let tickets = await manager.getTickets();
      let owner = await manager.ownerOf(tickets[0]);

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
      await manager.createTicket();

      let tickets = await manager.getTickets();

      assert.equal(1, tickets.length, "The length of the list should be one (1)");
    })
  });

  context("function: showTicketsByAddress", function () {
    it("Should show the tickets that are assigned to an address", async function () {
      await manager.createTicket({ from: admin });
      await manager.createTicket({ from: admin });
      await manager.createTicket({ from: bob });

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
      let owner = admin;
      let newOwner = bob;

      await manager.createTicket({ from: owner });
      let ownerTicket = (await manager.getTickets())[0];

      await manager.transferTicket(ownerTicket, newOwner, { from: owner });
      let ticketOwner = await manager.ownerOf(ownerTicket);

      assert.equal(ticketOwner, newOwner, "Only the owner should transfer tickets");
    })

    it("The admin, should change the owner of the ticket", async function () {
      let owner = bob;
      let newOwner = otherAccount;

      await manager.createTicket({ from: owner });
      let ownerTicket = (await manager.getTickets())[0];

      await manager.transferTicket(ownerTicket, newOwner, { from: admin });
      let newOwnerTicket = await manager.ownerOf(ownerTicket);

      assert.equal(newOwnerTicket, newOwner, "Only the owner should transfer tickets");
    })

    it("Should revert the transaction if another user than owner/admin tries to transfer the ticket", async function () {
      let owner = admin;
      let newOwner = bob;
      let notOwnerAdmin = bob;

      await manager.createTicket({ from: owner });
      let ownerTicket = (await manager.getTickets())[0];

      await utils.shouldThrow(
        manager.transferTicket(ownerTicket, newOwner, { from: notOwnerAdmin })
      )
      assert(true);
    })
  });

  context("function: changeTicketPrice", function () {
    it("The owner, should change the price of the ticket", async function () {
      let owner = bob;
      let newPrice = 100;

      await manager.createTicket({ from: owner });
      let aTicket = (await manager.getTickets())[0];

      await manager.changeTicketPrice(aTicket, { from: owner, value: newPrice });
      assert(true);

      let updatedPrice = await manager.getTicketPrice(aTicket);
      assert.equal(updatedPrice, newPrice);
    })

    it("The admin, should change the price of the ticket", async function () {
      let owner = bob;

      await manager.createTicket({ from: owner });
      let aTicket = (await manager.getTickets())[0];

      await manager.changeTicketPrice(aTicket, { from: admin, value: 100 });
      assert(true);
    })

    it("Should revert the transaction if another user than owner/admin tries to change ticket's price", async function () {
      let owner = admin;
      let notOwnerAdmin = bob;

      await manager.createTicket({ from: owner });
      let aTicket = (await manager.getTickets())[0];

      await utils.shouldThrow(
        manager.changeTicketPrice(aTicket, { from: notOwnerAdmin, value: 100 })
      );
      assert(true);
    })

    it("Should pay a commssion when change the price of the ticket", async function () {
      let owner = admin;
      let commission = 5;
      let newPrice = 100;

      await manager.createTicket({ from: owner });
      let aTicket = (await manager.getTickets())[0];

      await manager.changeTicketPrice(aTicket, { from: owner, value: newPrice });
      let balance = await web3.eth.getBalance(manager.address)

      assert.equal(balance, newPrice * commission / 100);
    })
  });

  context("function: showTicketInformation", function () {
    it("Should show Ticket information", async function () {
      let eventName = 'ticket1';
      let eventDate = 'ticket1';
      let price = 'ticket1';
      let eventDescription = 'ticket1';
      let ticketOwner = admin;

      await manager.createTicket();
      let aTicket = (await manager.getTickets())[0];
      let info = await manager.showTicketInformation(aTicket);
      // console.log(info)

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

    it("Should show Ticket information", async function () {
      let other = bob;
      let priceTicket1 = 5;
      let priceTicket2 = 6;

      await manager.createTicket({from: admin});
      await manager.createTicket({from: other});
      
      let adminTicket = (await manager.getTickets())[0];
      let otherTicket = (await manager.getTickets())[1];

      await manager.changeTicketPrice(adminTicket, { from: admin, value: priceTicket1 });
      await manager.changeTicketPrice(otherTicket, { from: admin, value: priceTicket2 });
      
      let info = await manager.showStatistics();
      let ticketCount = info[0]['words'][0];
      let totalPrice = info[1]['words'][0];

      assert.equal(ticketCount, 2);
      assert.equal(totalPrice, priceTicket1 + priceTicket2);
    })
  });

  context("function: removeTicket", function () {
    it("Should remove a ticket by index", async function () {
      await manager.createTicket({from: admin});
      await manager.removeTicket(0);

      let tickets = await manager.getTickets();

      assert.equal(tickets.length, 0);
    })
  });
});
