// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFT.sol";

contract AddressStats {
    Token public nft;

    constructor(Token _nft) {
        nft = _nft;
    }

    function countPrimes(address user) public view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 1; i <= 20; i++) {
            if (nft.ownerOf(i) == user && isPrime(i)) {
                count++;
            }
        }
        return count;
    }

    function isPrime(uint256 n) internal pure returns (bool) {
        if (n <= 1) {
            return false;
        }
        for (uint256 i = 2; i * i <= n; i++) {
            if (n % i == 0) {
                return false;
            }
        }
        return true;
    }
}
