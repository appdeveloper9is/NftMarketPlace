const MyNft = artifacts.require("MyNft");
const MarketPlace = artifacts.require("MarketPlace")

module.exports = function (deployer) {
 await deployer.deploy(MyNft);
 let nft = await MyNft.deployed()
  deployer.deploy(MarketPlace,nft.address,20);
};
