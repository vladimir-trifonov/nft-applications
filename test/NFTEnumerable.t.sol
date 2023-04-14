// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "forge-std/Test.sol";
import "../src/NFTEnumerable/NFTEnumerable.sol";
import "../src/NFTEnumerable/NFTStats.sol";

/**
 * @title NFTEnumerableTest
 * @dev This contract is used to test the functionality of the NFTEnumerable and NFTStats contracts.
 */
contract NFTEnumerableTest is Test {
    NFTEnumerable private enumerable;
    NFTStats private stats;

    /**
     * @dev Sets up the test environment by creating instances of NFTEnumerable, and NFTStats contracts.
     */
    function setUp() public {
        enumerable = new NFTEnumerable();
        stats = new NFTStats(enumerable);
    }

    /*
     * @dev Tests the constructor of the NFTEnumerable contract.
     */
    function testConstructor() public {
        // Verify the effects
        assertEq(enumerable.owner(), address(this));
    }

    /**
     * @dev This function test the number of prime numbers among the tokens owned by an address in an ERC721Enumerable contract.
     */
    function testCountPrimes() public {
        // Set up
        address buyer = vm.addr(1);
        vm.startBroadcast(buyer);

        // Call the function
        for (uint256 i = 1; i < 1001; i++) {
            enumerable.mint();
        }
        vm.stopBroadcast();
        
        // Verify the effects
        assertEq(stats.countPrimes(buyer), 168);
        assertEq(enumerable.balanceOf(buyer), 1000);
    }

    /**
     * @dev This function test contract withdraw method.
     */
    function testWithdraw() public {
        // Set up
        address buyer = vm.addr(1);
        address receiver = vm.addr(2);
        vm.deal(buyer, 0.1 ether);

        // Call the function
        vm.prank(buyer);
        enumerable.mint{value: 0.1 ether}();
        vm.prank(address(this));
        enumerable.withdraw(receiver);
        
        // Verify the effects
        assertEq(address(receiver).balance, 0.1 ether);
    } 
    
    /**
     * @dev This function test contract withdraw method reverts when the caller is not the owner.
     */
    function testRevert_WithdrawNotAnOwner() public {
        // Set up
        address buyer = vm.addr(1);
        uint256 balance = address(buyer).balance;
        vm.deal(buyer, 0.1 ether);
        vm.prank(buyer);
        enumerable.mint{value: 0.1 ether}();

        // Expect revert
        vm.expectRevert("Ownable: caller is not the owner");

        // Call the function
        vm.prank(buyer);
        enumerable.withdraw(vm.addr(2));

        // Verify the effects
        assertEq(address(buyer).balance, balance);
        assertEq(enumerable.owner(), address(this));
    }

    /**
     * @dev This function test contract withdraw method reverts when the caller zero address.
     */
    function testRevert_WithdrawZeroAddress() public {
        // Set up
        address buyer = vm.addr(1);
        uint256 balance = address(this).balance;
        vm.deal(buyer, 0.1 ether);
        vm.prank(buyer);
        enumerable.mint{value: 0.1 ether}();

        // Expect revert
        vm.expectRevert("Receiver is zero address");

        // Call the function
        vm.prank(address(this));
        enumerable.withdraw(address(0));

        // Verify the effects
        assertEq(address(this).balance, balance);
    }
}
