//SPDX-License-Identifier: un-licence
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarket is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;
    uint256 private fee;
    IERC721 private token;

    constructor(address _nftToken,uint256 _fee) {
        token = IERC721(_nftToken);
        fee = _fee; // i.e 20 => 20%
    }


    struct MarketItem {
        uint256 itemId;
        uint256 tokenId;
        uint256 price;
        address owner;
        bool forSale;
    }

    mapping(uint256 => MarketItem) private idToMarketItem;

    event MarketItemCreated(
        uint256 indexed itemId,
        uint256 indexed tokenId,
        uint256 price,
        address owner,
        bool forSale
    );
    event MarketItemUnListed(
        uint256 indexed itemId,
        uint256 indexed tokenId,
        uint256 price,
        address owner,
        bool forSale
    );
    event MarketItemSold(
        uint256 indexed itemId,
        uint256 indexed tokenId,
        uint256 price,
        address owner,
        bool forSale
    );

    event PriceChanged(uint256 _itemId, uint256 oldPrice, uint256 newPrice);

    function setFee(uint256 _fee)public onlyOwner{
        fee = _fee;
    }

    function getFee() public view returns(uint256){
        return fee;
    }

    function listItem(uint256 tokenId, uint256 price) public {
        require(msg.sender != address(0), "address should not be zero");
        require(
            token.getApproved(tokenId) == address(this),
            "Nft is not Approved. First Approve and then List"
        );
        require(
            token.ownerOf(tokenId) == msg.sender,
            "You don't own this item"
        );
    

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        idToMarketItem[itemId] = MarketItem(
            itemId,
            tokenId,
            price,
            payable(msg.sender),
            true
        );

        emit MarketItemCreated(itemId, tokenId, price, msg.sender, true);

         _itemsSold.increment();
    }


    function unList(uint256 _itemId) public {
        MarketItem storage market = idToMarketItem[_itemId];
        require(
            market.owner == msg.sender,
            "you can not unList this item, asyou are not the owner"
        );
        delete idToMarketItem[_itemId];
        emit MarketItemUnListed(
            market.itemId,
            market.tokenId,
            market.price,
            market.owner,
            market.forSale
        );
    }

    function buyNft(uint256 _itemId) public payable {
        require(msg.sender != address(0), "address should not be zero");

        MarketItem storage market = idToMarketItem[_itemId];


        require(
            msg.value == market.price,
            "amount not not equal to listing price"
        );
        address tokenOwner = token.ownerOf(market.tokenId);

        require(tokenOwner != msg.sender, "not owner");

        require(market.forSale, "not for sale");

        token.transferFrom(market.owner, msg.sender, market.tokenId);
        
        uint256 _fee = (market.price * fee) / 100;
        payable(owner()).transfer(_fee);
        
        payable(market.owner).transfer(msg.value - _fee);
        delete idToMarketItem[_itemId];


        emit MarketItemSold(
            market.itemId,
            market.tokenId,
            market.price,
            market.owner,
            market.forSale
        );
    }

    function changeTokenPrice(uint256 _itemId, uint256 _newPrice) public {
        require(msg.sender != address(0), "should not be zero address");

        MarketItem storage market = idToMarketItem[_itemId];

        uint256 _oldPrice = market.price;
        address tokenOwner = token.ownerOf(_itemId);

        require(tokenOwner == msg.sender, "caller should be owner");
        market.price = _newPrice;

        idToMarketItem[_itemId] = market;
        emit PriceChanged(_itemId, _oldPrice, _newPrice);
    }


      /* Returns all unsold market items */
  function fetchMarketItems() public view returns (MarketItem[] memory) {
    uint itemCount = _itemIds.current();
    uint unsoldItemCount = _itemIds.current() -_itemsSold.current();
    uint currentIndex = 0;

    MarketItem[] memory items = new MarketItem[](unsoldItemCount);
    for (uint i = 0; i < itemCount; i++) {
      if (idToMarketItem[i + 1].forSale) {
        uint currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  /* Returns onlyl items that a user has purchased */
  function fetchMyNFTs() public view returns (MarketItem[] memory) {
    uint totalItemCount = _itemIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;

    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].owner == msg.sender) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].owner == msg.sender) {
        uint currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

}
