const Migrations = artifacts.require("MyNft");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
};
