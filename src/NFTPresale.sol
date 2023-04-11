// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

/**
 * @title NFTPresale
 * @dev A contract for the sale of NFT tokens with presale functionality
 * Deployed on https://sepolia.etherscan.io/address/0xdc2c832b1a8ded3bc4a90e89d520015dec0969af
 */
contract NFTPresale is ERC721, IERC2981, Ownable {
    using BitMaps for BitMaps.BitMap;
    using Strings for uint256;

    // The maximum number of tokens that can be minted
    // To be gas efficient we start at 1001 so we can use
    // tokenId < MAX_SUPPLY instead of tokenId <= MAX_SUPPLY if MAX_SUPPLY == 1000
    uint256 constant MAX_SUPPLY = 1001;
    // The price in wei for a single token during the public sale
    uint256 public constant PRICE = 1_000_000;
    // The price in wei for a single token during the presale
    uint256 public constant PRESALE_PRICE = 500_000;
    // The percentage of the sale price that goes to the token creator as royalty
    uint256 constant ROYALTY_PERCENTAGE = 250;
    // The number of metadata items for the token
    uint256 constant METADATA_COUNT = 10;
    // The next available token ID
    // To be gas efficient we start at 1
    uint256 private nextTokenId = 1;
    // The Merkle root of the presale ticket list
    bytes32 private immutable merkleRoot;
    // A bitmap of presale tickets that have already been minted
    BitMaps.BitMap private tickets;
    // The address of the new owner of the contract
    address private pendingOwner;
    // A mapping of token IDs to their creators
    mapping(uint256 => address) private creators;

    /**
     * @dev Check if the contract supports a given interface ID
     * @param interfaceId The interface ID to check
     * @return A Returns true if the contract supports the interface, false otherwise
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, IERC165) returns (bool) {
        if (interfaceId == type(IERC2981).interfaceId) {
            return true;
        }
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Constructor for the NFTPresale contract
     * @param _merkleRoot The Merkle root of the presale ticket list
     */
    constructor(bytes32 _merkleRoot) ERC721("Presale Token", "PTK") {
        merkleRoot = _merkleRoot;
        // Set the first bit to 1 to avoid underflow when unsetting bits
        tickets._data[0] = type(uint256).max;
    }

    /**
     * @dev Transfer ownership of the contract to a new owner
     * @param _pendingOwner The address of the new owner
     */
    function transferOwnership(address _pendingOwner) public override onlyOwner {
        require(_pendingOwner != address(0), "New owner address cannot be zero");
        pendingOwner = _pendingOwner;
    }

    /**
     * @dev Accept ownership of the contract
     */
    function acceptOwnership() external {
        require(
            msg.sender == pendingOwner,
            "Only the new owner can accept ownership"
        );
        _transferOwnership(pendingOwner);
        pendingOwner = address(0);
    }

    /**
     * @dev Ovveride remove ownership of the contract
     */
    function renounceOwnership() public view override onlyOwner {
        revert("Cannot renounce ownership");
    }

    /**
     * @dev Mint a token for the sender during the public sale
     */
    function mint() external payable {
        require(msg.value == PRICE, "Insufficient funds");

        _mint(msg.sender, nextTokenId);
    }

    /**
     * @dev Mint a token for the sender during the presale
     * @param merkleProof The Merkle proof for the presale ticket
     * @param ticket The presale ticket ID
     */
    function presale(
        bytes32[] calldata merkleProof,
        uint256 ticket
    ) external payable {
        require(msg.value == PRESALE_PRICE, "Insufficient funds");
        require(tickets.get(ticket), "Already minted");
        require(_isValid(merkleProof, ticket), "Invalid merkle proof");

        tickets.unset(ticket);
        _mint(msg.sender, nextTokenId);
    }

    /**
     * @dev Mint a token with the given ID for the given recipient
     * @param to The recipient of the token
     * @param tokenId The ID of the token to mint
     */
    function _mint(address to, uint256 tokenId) internal override {
        require(tokenId < MAX_SUPPLY, "Sale has already ended");
        // require(tx.origin == msg.sender, "Contracts not allowed");

        creators[tokenId] = to;

        // Increment the nextTokenId and mint the token
        unchecked {
            nextTokenId++;
        }

        super._mint(to, tokenId);
    }

    /**
     * @dev Check if a presale ticket is valid
     * @param merkleProof The Merkle proof for the presale ticket
     * @param ticket The presale ticket ID
     * @return A Returns true if the ticket is valid, false otherwise
     */
    function _isValid(
        bytes32[] calldata merkleProof,
        uint256 ticket
    ) private view returns (bool) {
        return
            MerkleProof.verify(
                merkleProof,
                merkleRoot,
                keccak256(abi.encodePacked(msg.sender, ticket))
            );
    }

    /**
     * @dev Get the URI for the given token ID
     * @param tokenId The ID of the token to get the URI for
     * @return A The URI for the token
     */
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        uint256 matedataIndex = tokenId % METADATA_COUNT;
        // Return a concatenation of the base URI and the metadata index
        return
            string(
                abi.encodePacked(_baseURI(), matedataIndex.toString(), ".json")
            );
    }

    /**
     * @dev Get the base URI for the token metadata
     * @return A The base URI for the token metadata
     */
    function _baseURI() internal pure override returns (string memory) {
        return
            "ipfs://QmcnsDPCkUWCxFknXCgeJwKK9WbfeEa7ukVjEc35fgjf7R/";
    }

    /**
     * @dev Get the royalty information for the given token ID and sale price
     * @param tokenId The ID of the token to get the royalty information for
     * @param salePrice The sale price of the token
     * @return A The address of the token creator and the royalty amount
     */
    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view override returns (address, uint256) {
        // Calculate the royalty as a percentage of the sale price
        uint256 royalty = (salePrice * ROYALTY_PERCENTAGE) / 10000;
        return (creators[tokenId], royalty);
    }

    /**
     * @dev Withdraw the contract balance to the owner
     */
    function withdraw(address to) external onlyOwner {
        Address.sendValue(payable(to), address(this).balance);
    }

    /**
     * @dev Get the total number of tokens that have been minted
     * @return A The total number of minted tokens
     */
    function totalSupply() external view returns (uint256) {
        // Subtract 1 from nextTokenId to get the total number of minted tokens
        return nextTokenId - 1;
    }
}
