// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/NFTStaking/NFTStaking.sol";
import "../src/NFTStaking/Token.sol";
import "../src/NFTStaking/NFT.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

/*
 * @title NFTStakingTest
 * @dev This contract is a test contract for the NFTStaking contract.
 * It uses the Forge library for testing purposes.
 */
contract NFTStakingTest is Test {
    // Instance variables
    NFTStaking private staking;
    Token private erc20;
    NFT private nft;

    /**
     * @dev Sets up the test environment by creating instances of NFTStaking, Token, and NFT contracts.
     * Transfers ownership of the Token contract to the NFTStaking contract.
     */
    function setUp() public {
        nft = new NFT();
        erc20 = new Token("Staking Coin", "SCN");
        staking = new NFTStaking(nft, erc20);

        erc20.transferOwnership(address(staking));
    }

    /**
     * @dev Function to test the mint function of the NFT contract.
     */
    function testMint() public {
        // Set up
        address buyer = vm.addr(1);
        vm.broadcast(buyer);

        // Call the function
        nft.mint{value: 0}();

        // Verify the effects
        assertEq(nft.balanceOf(buyer), 1);
        assertEq(nft.ownerOf(1), buyer);
    }

    /**
     * @dev Function to test the stake function of the NFTStaking contract.
     */
    function testStake() public {
        // Set up
        address buyer = vm.addr(1);
        vm.broadcast(buyer);
        nft.mint{value: 0}();

        // Call the function
        vm.prank(buyer);
        nft.safeTransferFrom(buyer, address(staking), 1);

        // Verify the effects
        assertEq(nft.balanceOf(buyer), 0);
        assertEq(nft.ownerOf(1), address(staking));
    }

    /**
     * @dev Function to test that the claimReward function of the NFTStaking contract reverts if the time elapsed since the last reward is less than the reward interval.
     */
    function testRevert_ClaimTooSoon() public {
        // Set up
        address buyer = vm.addr(1);
        vm.broadcast(buyer);
        nft.mint{value: 0}();
        vm.prank(buyer);
        nft.safeTransferFrom(buyer, address(staking), 1);

        // Expect revert
        vm.expectRevert("Too soon to claim rewards");

        // Call the function
        vm.prank(buyer);
        staking.claimReward(1);
    }

    /**
     * @dev Function to test that the claimReward function of the NFTStaking contract reverts if the caller is not the original owner of the staked NFT.
     */
    function testRevert_ClaimNotOriginalOwner() public {
        // Set up
        address buyer = vm.addr(1);
        vm.broadcast(buyer);
        nft.mint{value: 0}();
        vm.prank(buyer);
        nft.safeTransferFrom(buyer, address(staking), 1);

        // Expect revert
        vm.expectRevert("Not staked or not original owner");

        // Call the function
        staking.claimReward(1);
    }

    /**
     * @dev Function to test that the claimReward function of the NFTStaking contract reverts if the specified NFT is not staked.
     */
    function testRevert_ClaimNotStaked() public {
        // Set up
        address buyer = vm.addr(1);
        vm.broadcast(buyer);
        nft.mint{value: 0}();
        vm.prank(buyer);
        nft.safeTransferFrom(buyer, address(staking), 1);

        // Expect revert
        vm.expectRevert("Not staked or not original owner");

        // Call the function
        vm.prank(buyer);
        staking.claimReward(2);
    }

    /**
     * @dev This function tests that a user can unstake their NFT from the contract, and the NFT is returned to the original owner.
     */
    function testUnstake() public {
        // Set up
        address buyer = vm.addr(1);
        vm.broadcast(buyer);
        nft.mint{value: 0}();
        vm.prank(buyer);
        nft.safeTransferFrom(buyer, address(staking), 1);

        // Call the function
        vm.prank(buyer);
        staking.unstake(1);

        // Verify the effects
        assertEq(nft.balanceOf(buyer), 1);
        assertEq(nft.balanceOf(address(staking)), 0);
        assertEq(nft.ownerOf(1), buyer);
    }

    /**
     * @dev This function tests that a user cannot claim rewards for an NFT that has already been unstaked.
     */
    function testRevert_ClaimUnstaked() public {
        // Set up
        address buyer = vm.addr(1);
        vm.broadcast(buyer);
        nft.mint{value: 0}();
        vm.prank(buyer);
        nft.safeTransferFrom(buyer, address(staking), 1);
        vm.prank(buyer);
        staking.unstake(1);

        // Expect revert
        vm.expectRevert("Not staked or not original owner");

        // Call the function
        vm.prank(buyer);
        staking.claimReward(1);
    }

    /**
     * @dev This function tests that a user can successfully claim rewards for staking their NFT in the contract.
     * The function checks that the user receivedERC20 tokens as rewards and that the next claim time has been updated appropriately.
     */
    function testClaim() public {
        // Set up
        uint256 rewardAmount = staking.REWARD_AMOUNT();
        uint256 rewardInterval = staking.REWARD_INTERVAL();
        address buyer = vm.addr(1);
        uint256 tokenId = 1;
        vm.broadcast(buyer);
        nft.mint{value: 0}();
        vm.prank(buyer);
        vm.warp(0);
        nft.safeTransferFrom(buyer, address(staking), tokenId);

        // Call the function
        vm.prank(buyer);
        skip((2 * rewardInterval) + 1);
        staking.claimReward(tokenId);

        // Verify the effects
        assertEq(erc20.balanceOf(buyer), 2 * rewardAmount);
        assertEq(staking.nextClaim(tokenId), rewardInterval);
    }
}
