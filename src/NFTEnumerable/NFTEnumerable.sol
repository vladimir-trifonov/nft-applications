// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

/*
 * @title NFTEnumerable
 * @dev This contract is an ERC721 token contract that allows users to mint new tokens and provides enumeration functionality.
 */
contract NFTEnumerable is ERC721Enumerable {
    uint256 private nextTokenId = 1;

    /**
     * @dev Constructor function sets the name and symbol of the ERC721 token.
     */
    constructor() ERC721("Enumerable Token", "ETK") {}

    /**
     * @dev Function that allows users to mint new tokens.
     */
    function mint() external payable {
        _mint(msg.sender, nextTokenId);

        unchecked {
            nextTokenId++;
        }
    }
}