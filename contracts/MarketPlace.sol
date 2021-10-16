//SPDX-License-Identifier: un-licence
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    uint256 private counter = 0;

    address payable owner;
    IERC721 private token;

    constructor(address _nftToken) {
        token = IERC721(_nftToken);
        owner = payable(msg.sender);
    }

    struct MarketItem {
        uint256 itemId;
        uint256 tokenId;
        uint256 price;
        address payable seller;
        address payable owner;
        bool forSale;
    }

    mapping(uint256 => MarketItem) private idToMarketItem;

    event MarketItemCreated(
        uint256 indexed itemId,
        uint256 indexed tokenId,
        uint256 price,
        address seller,
        address owner,
        bool sold
    );

    function listItem(uint256 tokenId, uint256 price) public {
        uint256 itemId = _itemIds.current();

        idToMarketItem[itemId] = MarketItem(
            itemId,
            tokenId,
            price,
            payable(msg.sender),
            payable(address(0)),
            true
        );

        emit MarketItemCreated(
            itemId,
            tokenId,
            price,
            msg.sender,
            address(0),
            true
        );
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
        delete idToMarketItem[_itemId];
    }

    function buyNft(uint256 _itemId) public payable {
        require(msg.sender != address(0), "address should not be zero");

        MarketItem storage market = idToMarketItem[_itemId];

        address tokenOwner = IERC721(token).ownerOf(
            market.tokenId
        );

        require(
            msg.value == market.price,
            "amount not not equal to listing price"
        );

        require(tokenOwner != address(0), "should not be zero address");

        require(tokenOwner != msg.sender, "not owner");

        require(market.forSale, "not for sale");

        IERC721(token).transferFrom(
            market.seller,
            msg.sender,
            market.tokenId
        );

        address payable sendTo = market.owner;

        payable(sendTo).transfer(msg.value);

        delete idToMarketItem[_itemId];

        counter--;
    }

    function changeTokenPrice(uint256 _tokenId, uint256 _newPrice) public {
        require(msg.sender != address(0), "should not be zero address");

        MarketItem storage market = idToMarketItem[_tokenId];

        market.price = _newPrice;

        address tokenOwner = IERC721(token).ownerOf(_tokenId);

        require(tokenOwner == msg.sender, "caller should be owner");

        idToMarketItem[_tokenId] = market;
    }
}
