pragma solidity ^0.8.0;

import "./ERC721Tradeable.sol";



contract MyNft is ERC721Tradable{
    constructor() 
         ERC721Tradable("MyNft","MN","https://opensea-creatures-api.herokuapp.com/api/creature/", 0xF57B2c51dED3A29e6891aba85459d600256Cf317){
             
         }

} 