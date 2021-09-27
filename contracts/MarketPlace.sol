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
    uint256 price;
    address payable seller;
    address payable owner;
    bool forSale;
  }


  mapping(uint256 => MarketItem) private idToMarketItem;


  event MarketItemCreated ( uint indexed itemId,address indexed nftContract,uint256 indexed tokenId,uint256 price,address seller,address owner,bool sold
  );
  
  
  
   function listItem(
    address nftContract,
    uint256 tokenId,
    uint256 price
  ) public {


    _itemIds.increment();
    uint256 itemId = _itemIds.current();
  
    idToMarketItem[itemId] =  MarketItem(
      itemId,
      nftContract,
      tokenId,
      price,
      payable(msg.sender),
      payable(address(0)),
      true
    );
      emit MarketItemCreated(
      itemId,
      nftContract,
      tokenId,
      price,
      msg.sender,
      address(0),
      true
    );
  }
  

  
 
  function buyNft(uint256 _tokenId) public payable {
     
  
    require(msg.sender != address(0), "address should not be zero");
   
    
    
    MarketItem storage market = idToMarketItem[_tokenId];
  
    address tokenOwner = IERC721(market.nftContract).ownerOf(_tokenId);
    
    require(msg.value == market.price , "amount not not equal to listing price");

    require(tokenOwner != address(0), "should not be zero address" );
   
    require(tokenOwner != msg.sender, "not owner");
  
    require(market.forSale, "not for sale");
   
    IERC721(market.nftContract).transferFrom(tokenOwner, msg.sender, _tokenId);
  
    address payable sendTo = market.owner;
  
    payable(sendTo).transfer(msg.value);
 
    delete idToMarketItem[_tokenId];
      
  }
  
   function changeTokenPrice(uint256 _tokenId, uint256 _newPrice) public {
   
    require(msg.sender != address(0), "should not be zero address");
 
     MarketItem storage market = idToMarketItem[_tokenId];
     
     market.price = _newPrice;
  
    address tokenOwner = IERC721(market.nftContract).ownerOf(_tokenId);
   
    require(tokenOwner == msg.sender, "caller should be owner");
    
    idToMarketItem[_tokenId] = market;
  }

}