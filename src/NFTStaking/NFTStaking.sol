// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract StakingContract is ERC721Holder {
    using SafeMath for uint256;

    IERC20 public token;
    IERC721 public nft;
    uint256 public rewardRate;
    uint256 public rewardAmount;
    uint256 public lastUpdateTime;
    uint256 public totalStaked;
    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public lastClaimTime;

    constructor(IERC20 _token, IERC721 _nft, uint256 _rewardRate, uint256 _rewardAmount) {
        token = _token;
        nft = _nft;
        rewardRate = _rewardRate;
        rewardAmount = _rewardAmount;
    }

    function stake(address to) public {
        require(nft.getApproved(msg.sender, address(this)) == true, "NFT must be approved");
        require(stakedBalance[to] == 0, "Address has already staked an NFT");

        nft.safeTransferFrom(msg.sender, address(this), nft.tokenOfOwnerByIndex(msg.sender, 0));
        lastClaimTime[to] = block.timestamp;
        stakedBalance[to] = rewardAmount;
        totalStaked = totalStaked.add(rewardAmount);
    }

    function unstake() public {
        require(stakedBalance[msg.sender] > 0, "Address has no staked balance");

        uint256 reward = calculateReward(msg.sender);
        token.transfer(msg.sender, reward);

        nft.safeTransferFrom(address(this), msg.sender, nft.tokenOfOwnerByIndex(address(this), 0));
        totalStaked = totalStaked.sub(stakedBalance[msg.sender]);
        stakedBalance[msg.sender] = 0;
        lastClaimTime[msg.sender] = 0;
    }

    function calculateReward(address user) public view returns (uint256) {
        uint256 timeElapsed = block.timestamp.sub(lastClaimTime[user]);
        uint256 stakedAmount = stakedBalance[user];
        uint256 reward = stakedAmount.mul(rewardRate).mul(timeElapsed).div(1 days);

        return reward;
    }

    function claim() public {
        uint256 reward = calculateReward(msg.sender);
        lastClaimTime[msg.sender] = block
