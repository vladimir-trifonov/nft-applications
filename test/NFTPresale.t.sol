// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/NFTPresale.sol";

contract NFTPresaleTest is Test {
  bytes32 private constant MERKLE_ROOT = bytes32(hex"fcf019a5d0c48e09ca5b7a9d5f5e5d5dd23c2073e3613d98ce056b7d5f2eb276");
  uint256 private constant PRESALE_PRICE = 500_000;
  uint256 private constant PRICE = 1_000_000;

  NFTPresale private nftPresale;

  function setUp() public {
    nftPresale = new NFTPresale(MERKLE_ROOT);
    presale.mint{value: 1_000_000}();
  }

  function testConstructor() public {
    assertEq(presale.owner(), address(this));
    assertEq(presale.name(), "Presale Token");
    assertEq(presale.symbol(), "PTK");
    assertEq(presale.totalSupply(), 1);
    assertEq(presale.royaltyInfo(tokenId, 1_000_000), (address(this), 250));
  }
}
