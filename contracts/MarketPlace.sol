pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";



contract NFTMarket is ReentrancyGuard {
  using Counters for Counters.Counter;
  Counters.Counter private _itemIds;
  Counters.Counter private _itemsSold;

  address payable owner;

  constructor() {
    owner = payable(msg.sender);
  }

  struct MarketItem {
    uint itemId;
    address nftContract;
    uint256 tokenId;
    address payable seller;
    address payable owner;
    bool forSale;
  }


  mapping(uint256 => MarketItem) private idToMarketItem;

  event MarketItemCreated ( uint indexed itemId,address indexed nftContract,uint256 indexed tokenId,address seller,address owner,bool sold
  );

  /* Returns the listing price of the contract */


   function createMarketItem(
    address nftContract,
    uint256 tokenId
  ) public payable nonReentrant {


    _itemIds.increment();
    uint256 itemId = _itemIds.current();
  
    idToMarketItem[itemId] =  MarketItem(
      itemId,
      nftContract,
      tokenId,
      payable(msg.sender),
      payable(address(0)),
      false
    );

    IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
      emit MarketItemCreated(
      itemId,
      nftContract,
      tokenId,
      msg.sender,
      address(0),
      false
    );
  }
  

  
  
  function listUnList(uint256 _tokenId) public{
      
    require(msg.sender != address(0));
    MarketItem memory market = idToMarketItem[_tokenId];
    // require that token should exist
    // get the token's owner
    address tokenOwner = IERC721(market.nftContract).ownerOf(_tokenId);
    // check that token's owner should be equal to the caller of the function
    require(tokenOwner == msg.sender);
    // get that token from all crypto boys mapping and create a memory of it defined as (struct => CryptoBoy)
   
    // if token's forSale is false make it true and vice versa
    if(market.forSale) {
      market.forSale = false;
    } else {
      market.forSale = true;
    }
    // set and update that token in the mapping
    idToMarketItem[_tokenId] = market;
      
}
      // by a token by passing in the token's id
  function buyNft(uint256 _tokenId) public payable {
     
    // check if the function caller is not an zero account address
    require(msg.sender != address(0), "address should not be zero");
    MarketItem storage market = idToMarketItem[_tokenId];
    // check if the token id of the token being bought exists or not

    // get the token's owner
    address tokenOwner = IERC721(market.nftContract).ownerOf(_tokenId);
    // token's owner should not be an zero address account
    require(tokenOwner != address(0), "should not be zero address" );
    // the one who wants to buy the token should not be the token's owner
    require(tokenOwner != msg.sender, "not owner");
    // get that token from all crypto boys mapping and create a memory of it defined as (struct => CryptoBoy)
    
    // price sent in to buy should be equal to or more than the token's price
    // token should be for sale
    require(market.forSale, "not for sale");
    // transfer the token from owner to the caller of the function (buyer)
    IERC721(market.nftContract).transferFrom(address(this), msg.sender, _tokenId);
    // get owner of the token
    address payable sendTo = market.owner;
    // send token's worth of ethers to the owner
    payable(sendTo).transfer(msg.value);
    // update the token's previous owner
    delete idToMarketItem[_tokenId];
      
  }
  
   function changeTokenPrice(uint256 _tokenId, uint256 _newPrice) public {
    // require caller of the function is not an empty address
    require(msg.sender != address(0));
    // require that token should exist
     MarketItem storage market = idToMarketItem[_tokenId];
    // get the token's owner
    address tokenOwner = IERC721(market.nftContract).ownerOf(_tokenId);
    // check that token's owner should be equal to the caller of the function
    require(tokenOwner == msg.sender);
    // get that token from all crypto boys mapping and create a memory of it defined as (struct => CryptoBoy)
   
    // update token's price with new price
    // set and update that token in the mapping
    idToMarketItem[_tokenId] = market;
  }

}