// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IToken.sol";

/*
 * @title NFTStaking
 * @dev This contract allows users to stake their NFTs to earn ERC20 tokens as rewards.
 * The contract inherits from IERC721Receiver and ReentrancyGuard.
 */
contract NFTStaking is IERC721Receiver, ReentrancyGuard {
    // ERC20 token and NFT token contracts
    IToken private erc20Token;
    IERC721 private erc721Token;

    // Reward amount and interval
    uint256 public constant REWARD_AMOUNT = 10 * 10 ** 18; // 10 tokens with 18 decimals
    uint256 public constant REWARD_INTERVAL = 1 days;

    // Mapping of staked NFTs to their owner address
    mapping(uint256 => address) private nftStaked;
    // Mapping of last claimed reward time for each staked NFT
    mapping(uint256 => uint256) private lastClaimed;

    // Events
    event Staked(address indexed account, uint256 tokenId);
    event Unstaked(address indexed account, uint256 tokenId);
    event RewardClaimed(address indexed account, uint256 amount);

    /**
     * @dev Constructor function sets the ERC721 and ERC20 token contracts.
     * @param _erc721Token address of the ERC721 token contract.
     * @param _erc20Token address of the ERC20 token contract.
     */
    constructor(IERC721 _erc721Token, IToken _erc20Token) {
        erc721Token = _erc721Token;
        erc20Token = _erc20Token;
    }

    /**
     * @dev Function that is called when an NFT is staked to the contract.
     * @param from address of the NFT owner.
     * @param tokenId ID of the NFT being staked.
     */
    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        require(msg.sender == address(erc721Token), "Invalid NFT token");
        require(nftStaked[tokenId] == address(0), "NFT is staked");

        nftStaked[tokenId] = from;
        lastClaimed[tokenId] = block.timestamp;

        emit Staked(from, tokenId);

        return this.onERC721Received.selector;
    }

    /**
     * @dev Function that allows the NFT owner to claim their reward.
     * @param tokenId ID of the staked NFT.
     */
    function claimReward(uint256 tokenId) external nonReentrant {
        require(
            nftStaked[tokenId] == msg.sender,
            "Not staked or not original owner"
        );

        _claimReward(tokenId);
    }

    /**
     * @dev Internal function that handles the claiming of rewards.
     * @param tokenId ID of the staked NFT.
     */
    function _claimReward(uint256 tokenId) private {
        uint256 timeElapsed = block.timestamp - lastClaimed[tokenId];

        require(timeElapsed > REWARD_INTERVAL, "Too soon to claim rewards");

        uint256 reward = REWARD_AMOUNT * (timeElapsed /
            REWARD_INTERVAL);
        lastClaimed[tokenId] = block.timestamp;

        erc20Token.mint(msg.sender, reward);

        emit RewardClaimed(msg.sender, reward);
    }

    /**
     * @dev Function that allows the NFT owner to unstake
     * their NFT and claim their reward if it is available.
     * @param tokenId ID of the staked NFT.
     */
    function unstake(uint256 tokenId) external nonReentrant {
        require(
            nftStaked[tokenId] == msg.sender,
            "Not staked or not original owner"
        );

        // If the reward is available, claim it before unstaking the NFT
        if (nextClaim(tokenId) == 0) {
            _claimReward(tokenId);
        }

        delete nftStaked[tokenId];
        delete lastClaimed[tokenId];

        // Transfer the NFT back to the owner
        erc721Token.safeTransferFrom(address(this), msg.sender, tokenId);

        emit Unstaked(msg.sender, tokenId);
    }

    /**
     * @dev Function that returns the time remaining until the next reward claim is available.
     * @param tokenId ID of the staked NFT.
     * @return The time remaining in seconds until the next reward claim is available.
     */
    function nextClaim(uint256 tokenId) public view returns (uint256) {
        if (lastClaimed[tokenId] == 0) {
            return 0;
        }
        uint256 timeElapsed = block.timestamp - lastClaimed[tokenId];
        if (timeElapsed >= REWARD_INTERVAL) {
            return 0;
        }
        return REWARD_INTERVAL - timeElapsed;
    }
}
