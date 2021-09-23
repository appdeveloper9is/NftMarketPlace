const Migrations = artifacts.require("MarketPlace");


module.exports = function (deployer) {
  deployer.deploy(Migrations);
};
