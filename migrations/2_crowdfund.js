const Crowdfund = artifacts.require("Crowdfund");

module.exports = function(deployer) {
  deployer.deploy(Crowdfund);
};
