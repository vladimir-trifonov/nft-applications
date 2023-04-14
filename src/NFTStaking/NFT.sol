// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/*
 * @title NFT
 * @dev This contract is an ERC721 token contract that allows users to mint new tokens.
 */

contract NFT is ERC721, Ownable {
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

    /**
     * @dev Function that withdraws the ether from the contract.
     */
    function withdraw(address receiver) external onlyOwner {
        require(receiver != address(0), "Receiver is zero address");
        Address.sendValue(payable(receiver), address(this).balance);
    }
}
