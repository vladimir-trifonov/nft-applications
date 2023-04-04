// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/*
 * @title NFT
 * @dev This contract is an ERC721 token contract that allows users to mint new tokens.
 */

contract NFT is ERC721 {
    uint256 private nextTokenId = 1;

    /**
     * @dev Constructor function sets the name and symbol of the ERC721 token.
     */
    constructor() ERC721("Staking Token", "STK") {}

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
