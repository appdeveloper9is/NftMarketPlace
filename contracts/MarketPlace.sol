//SPDX-License-Identifier: un-licence
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarket is ReentrancyGuard,Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    uint256 private counter = 0;
    uint256 private fee;
    IERC721 private token;

    constructor(address _nftToken,uint256 _fee) {
        token = IERC721(_nftToken);
        fee = _fee;
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
        require(
            token.ownerOf(tokenId) == msg.sender,
            "You don't own this item"
        );
        require(
            token.isApprovedForAll(msg.sender, address(this)),
            "Nft is not Approved. First Approve and then List"
        );

        uint256 itemId = _itemIds.current();

        idToMarketItem[itemId] = MarketItem(
            itemId,
            tokenId,
            price,
            payable(msg.sender),
            true
        );

        emit MarketItemCreated(itemId, tokenId, price, msg.sender, true);
        _itemIds.increment();

        counter++;
    }

    function getListing() public view returns (MarketItem[] memory) {
        MarketItem[] memory listedItems = new MarketItem[](counter);
        if (counter == 0) {
            return listedItems;
        }
        for (uint256 i = 0; i < counter; i++) {
            if (idToMarketItem[i].forSale == true) {
                listedItems[i] = idToMarketItem[i];
            }
        }
        return listedItems;
    }

    function unList(uint256 _itemId) public {
        MarketItem storage market = idToMarketItem[_itemId];
        require(
            market.owner == msg.sender,
            "you can not unList this item, asyou are not the owner"
        );
        emit MarketItemUnListed(
            market.itemId,
            market.tokenId,
            market.price,
            market.owner,
            market.forSale
        );
        delete idToMarketItem[_itemId];
    }

    function buyNft(uint256 _itemId) public payable {
        require(msg.sender != address(0), "address should not be zero");

        MarketItem storage market = idToMarketItem[_itemId];

        address tokenOwner = IERC721(token).ownerOf(market.tokenId);

        require(
            msg.value == market.price,
            "amount not not equal to listing price"
        );

        require(tokenOwner != address(0), "should not be zero address");

        require(tokenOwner != msg.sender, "not owner");

        require(market.forSale, "not for sale");

        IERC721(token).transferFrom(market.owner, msg.sender, market.tokenId);

        payable(market.owner).transfer(msg.value);

        delete idToMarketItem[_itemId];

        counter--;

        emit MarketItemSold(
            market.itemId,
            market.tokenId,
            market.price,
            market.owner,
            market.forSale
        );
    }

    function changeTokenPrice(uint256 _tokenId, uint256 _newPrice) public {
        require(msg.sender != address(0), "should not be zero address");

        MarketItem storage market = idToMarketItem[_tokenId];

        uint256 _oldPrice = market.price;
        address tokenOwner = IERC721(token).ownerOf(_tokenId);

        require(tokenOwner == msg.sender, "caller should be owner");
        market.price = _newPrice;

        idToMarketItem[_tokenId] = market;

        emit PriceChanged(_tokenId, _oldPrice, _newPrice);
    }
}
