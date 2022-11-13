var ManagerContract = artifacts.require("Manager");

module.exports = function(_deployer) {
  _deployer.deploy(ManagerContract);
};