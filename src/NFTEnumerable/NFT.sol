// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Token is ERC721Enumerable {
    constructor() ERC721("Enumerable NFT", "ENFT") {}

    function mint(address to, uint256 tokenId) public {
        require(tokenId > 0 && tokenId <= 20, "Token ID must be between 1 and 20");
        _mint(to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
