// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IToken {
    /**
     * @dev Function that mints new tokens and sends them to a specified address.
     * @param to address to receive the newly minted tokens.
     * @param amount number of tokens to mint.
     */
    function mint(address to, uint256 amount) external;
}
