// SPDX-License-Identifier: MIT
// i love you
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";



contract ColorFields is ERC721Enumerable, ERC2981, Ownable {
    using Counters for Counters.Counter;

    uint256 public constant MAX_ID = 69;
    uint256 public price; 
    string public baseUri;

    address private royaltyReceiver = 0xf76B00b44F70a377acE77d5C0A4Eeb6AEa1a7671;
    
    bool public publicMintOpen = false;

    Counters.Counter private _tokenIdCounter;

    constructor(string memory _setBaseUri) 
        ERC721(
            "Canto Color Fields",
            "CLRFLD"
        ){
            baseUri = _setBaseUri;
            _setDefaultRoyalty(royaltyReceiver, uint96(1000));
        }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, Strings.toString(tokenId), ".json")) : "";
    }

    function publicMint() public payable {
        require(publicMintOpen, "CLOSED");
        require(msg.value == price, "Wrong Amount");
        repMint();
    }
    function repMint() internal {
        require(totalSupply() < MAX_ID, "SOLD OUT");
        uint256 tokenId = _tokenIdCounter.current() + 1;
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseUri;
    }


    // owner only 
    
    function setPrice(uint256 _price) public onlyOwner {
    price = _price;
    }

    function editMintWindows(bool _publicMintOpen ) external onlyOwner {
        publicMintOpen = _publicMintOpen;
    }

    function updateRoyalties(address newRoyaltyReceiver, uint96 newNumerator) external onlyOwner {
        _setDefaultRoyalty(newRoyaltyReceiver, newNumerator);
    }

    function setBaseURI(string memory newBaseURI) external onlyOwner {
        baseUri = newBaseURI;
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721Enumerable, ERC2981) returns (bool) {
        return  interfaceId == type(IERC721Enumerable).interfaceId ||
                interfaceId == type(IERC2981).interfaceId ||
                super.supportsInterface(interfaceId);
    }

    function withdraw(address _addr) external onlyOwner{
    uint256 balance = address(this).balance;
    payable(_addr).transfer(balance);
}
}
        
