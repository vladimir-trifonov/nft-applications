// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

/*
 * @title NFTStats
 * @dev This contract provides a function that counts the number of prime numbers in an owner's NFT collection.
 */
contract NFTStats {
    // ERC721 token contract
    IERC721Enumerable private erc721Token;

    /**
     * @dev Constructor function sets the ERC721 token contract.
     * @param _erc721Token address of the ERC721 token contract.
     */
    constructor(IERC721Enumerable _erc721Token) {
        erc721Token = _erc721Token;
    }

    /**
     * @dev Function that counts the number of prime numbers in an owner's NFT collection.
     * @param account address of the NFT owner.
     * @return The number of prime numbers in the owner's NFT collection.
     */
    function countPrimes(address account) external view returns (uint256) {
        uint256 count = 0;
        uint256 balance = erc721Token.balanceOf(account);
        for (uint256 i = 0; i < balance; i++) {
            if (_isPrime(erc721Token.tokenOfOwnerByIndex(account, i))) {
                unchecked {
                    count++;
                }
            }
        }
        return count;
    }

    /**
     * @dev Internal function that checks if a given number is prime.
     * @param number the number to check for primality.
     * @return A Returns true if the number is prime, false otherwise.
     */
    function _isPrime(uint256 number) private pure returns (bool) {
        if (number < 2) {
            return false;
        }

        if (number == 2 || number == 3) {
            return true;
        }

        if (number % 2 == 0) {
            return false;
        }

        for (uint256 i = 3; i * i <= number; i += 2) {
            if (number % i == 0) {
                return false;
            }
        }

        return true;
    }
}
