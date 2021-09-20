pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";

contract MyNft is ERC721PresetMinterPauserAutoId{

        ERC721PresetMinterPauserAutoId public nft;

    constructor() ERC721PresetMinterPauserAutoId("MyNft","MN","https://gas-free-nft.herokuapp.com/getMetaData/"){

        
    }

    


} 