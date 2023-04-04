// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../src/ReentrancyAttacks/Overmint1Hack.sol";
import "../src/ReentrancyAttacks/Overmint1.sol";

/*
 * @title Overmint1HackTest
 * @dev This contract is a test contract for the Overmint1Hack contract.
 */
contract Overmint1HackTest is Test {
    Overmint1Hack private hack;
    Overmint1 private nft;

    /**
     * @dev Sets up the test environment by creating instances of Overmint1Hack, and Overmint1 contracts.
     */
    function setUp() public {
        nft = new Overmint1();
        hack = new Overmint1Hack(nft);
    }

    /*
     * @dev Initiates the hack by calling the `hack` function on the Overmint1 contract.
     */
    function testHackMint() public {
        // Set up
        address hacker = vm.addr(1);

        // Call the function
        vm.prank(hacker);
        hack.hack();

        // Verify the effects
        assertTrue(nft.success(address(hack)));
    }
}
