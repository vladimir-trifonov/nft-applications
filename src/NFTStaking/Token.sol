// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IToken.sol";

/*
 * @title Token - A custom ERC20 token contract with minting capabilities
 * @dev This contract extends the OpenZeppelin ERC20 and Ownable contracts, and implements the IToken interface
 * The owner of the contract has the ability to mint new tokens
 */
contract Token is ERC20, Ownable, IToken {
    /*
     * @dev Constructs a new Token contract with a specified name and symbol
     * @param name The name of the token
     * @param symbol The symbol of the token
     */
    constructor(
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) Ownable() {}

    /*
     * @dev Mints a specified amount of tokens and transfers them to the specified recipient address
     * This function can only be called by the contract owner
     * @param to The address to receive the minted tokens
     * @param amount The amount of tokens to be minted
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
