// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "forge-std/Test.sol";
import "../src/NFTPresale.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

/*
 * @title NFTPresaleTest
 * @dev A test suite for the NFTPresale contract.
 */
contract NFTPresaleTest is Test {
    using Strings for uint256;

    // Test constants
    bytes32 private constant MERKLE_ROOT =
        bytes32(
            hex"f37e01f032bc851f888e3760a4d970e3c7bdd35594484fe0404b23fdf101df04"
        );
    uint256 constant MAX_SUPPLY = 1001;
    uint256 constant METADATA_COUNT = 10;
    uint256 private presalePrice;
    uint256 private price;
    string constant BASE_URI =
        "ipfs://QmcnsDPCkUWCxFknXCgeJwKK9WbfeEa7ukVjEc35fgjf7R/";

    NFTPresale private presale;

    /*
     * @dev Sets up the test by deploying a new NFTPresale contract instance.
     */
    function setUp() public {
        presale = new NFTPresale(MERKLE_ROOT);

        presalePrice = presale.PRESALE_PRICE();
        price = presale.PRICE();
    }

    /*
     * @dev Tests whether the NFTPresale contract supports IERC2981.
     */
    function testSupportsIERC2981() public {
        // Set up
        bytes4 interfaceId = type(IERC2981).interfaceId;

        // Verify the effects
        assertTrue(presale.supportsInterface(interfaceId));
    }

    /*
     * @dev Tests whether the NFTPresale contract does not support an invalid interface.
     */
    function testSupportsInvalidInterface() public {
        // Set up
        bytes4 interfaceId = bytes4(keccak256("invalidInterface()"));

        // Verify the effects
        assertFalse(presale.supportsInterface(interfaceId));
    }

    /*
     * @dev Tests the constructor of the NFTPresale contract.
     */
    function testConstructor() public {
        // Verify the effects
        assertEq(presale.owner(), address(this));
        assertEq(presale.name(), "Presale Token");
        assertEq(presale.symbol(), "PTK");
        assertEq(presale.totalSupply(), 0);
    }

    /*
     * @dev Tests the transfer of ownership in the NFTPresale contract.
     */
    function testTransferOwnership() public {
        // Set up
        address newOwner = vm.addr(1);
        presale.transferOwnership(newOwner);
        assertEq(presale.owner(), address(this));
        hoax(newOwner);

        // Call the function
        presale.acceptOwnership();

        // Verify the effects
        assertEq(presale.owner(), newOwner);
    }

    /*
     * @dev Tests the transfer of ownership in the NFTPresale contract when the caller is not the owner.
     */
    function testRevert_TransferOwnershipNotAnOwner() public {
        // Set up
        address newOwner = vm.addr(1);

        // Expect revert
        vm.expectRevert("Ownable: caller is not the owner");

        // Call the function
        vm.prank(newOwner);
        presale.transferOwnership(newOwner);

        // Verify the effects
        assertEq(presale.owner(), address(this));
    }

    /*
     * @dev Tests the revert of renouncing ownership in the NFTPresale contract.
     */
    function testRevert_RenounceOwnership() public {
        // Expect revert
        vm.expectRevert("Cannot renounce ownership");

        // Call the function
        presale.renounceOwnership();
    } 
    
    /*
     * @dev Tests the renounce of ownership in the NFTPresale contract when the caller is not the owner.
     */
    function testRevert_RenounceOwnershipNotAnOwner() public {
        // Expect revert
        vm.expectRevert("Ownable: caller is not the owner");

        // Call the function
        vm.prank(vm.addr(1));
        presale.renounceOwnership();

        // Verify the effects
        assertEq(presale.owner(), address(this));
    }

    /*
     * @dev Tests the minting of tokens in the NFTPresale contract.
     */
    function testMint() public {
        // Set up
        address buyer = vm.addr(1);
        vm.deal(buyer, price);
        vm.broadcast(buyer);

        // Call the function
        presale.mint{value: price}();

        // Verify the effects
        assertEq(presale.totalSupply(), 1);
        assertEq(presale.balanceOf(buyer), 1);
        assertEq(presale.ownerOf(1), buyer);
    }

    /*
     * @dev Tests the revert of minting when the sale has already ended.
     */
    function testRevert_SaleEnded() public {
        // Set up
        address buyer = vm.addr(1);
        for (uint256 i = 1; i < MAX_SUPPLY; i++) {
            vm.deal(buyer, price);
            vm.broadcast(buyer);
            presale.mint{value: price}();
        }

        // Expect revert
        vm.expectRevert("Sale has already ended");

        // Call the function
        vm.deal(buyer, price);
        vm.broadcast(buyer);
        presale.mint{value: price}();
    }

    /*
     * @dev Tests the revert of presale minting with an invalid Merkle proof.
     */
    function testRevert_PresaleInvalidMerkleProof() public {
        // Set up
        address buyer = vm.addr(1);
        bytes32[] memory invalidProof = new bytes32[](1);
        invalidProof[0] = bytes32(
            hex"0000000000000000000000000000000000000000000000000000000000000000"
        );

        // Expect revert
        vm.expectRevert("Invalid merkle proof");

        // Call the function
        hoax(buyer);
        presale.presale{value: presalePrice}(invalidProof, 0);
    }

    /*
     * @dev Tests the successful presale minting.
     */
    function testPresale() public {
        // Set up
        address buyer = address(0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB);
        bytes32[] memory proof = new bytes32[](3);
        proof[0] = bytes32(
            hex"bd555f4c1d283441246e3b8081e994217b8109898aa1ac2c652b4b5e1d745d4d"
        );
        proof[1] = bytes32(
            hex"2a7f7a3b505f2b03fd3189d07548a1143d736cb5d472b016a9f0b5c95d0a1fbf"
        );
        proof[2] = bytes32(
            hex"e94c52de115f43e549267af35e5bf6a7cb0f9d35b3a7eb3cad31b25cd19065af"
        );

        // Call the function
        vm.deal(buyer, presalePrice);
        vm.broadcast(buyer);
        presale.presale{value: presalePrice}(proof, 3);

        // Verify the effects
        assertEq(presale.totalSupply(), 1);
        assertEq(presale.balanceOf(buyer), 1);
        assertEq(presale.ownerOf(1), buyer);
    }

    /*
     * @dev Tests the revert of presale minting with an invalid ticket.
     */
    function testRevert_PresaleInvalidTicket() public {
        // Set up
        address buyer = address(0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB);
        bytes32[] memory proof = new bytes32[](3);
        proof[0] = bytes32(
            hex"bd555f4c1d283441246e3b8081e994217b8109898aa1ac2c652b4b5e1d745d4d"
        );
        proof[1] = bytes32(
            hex"2a7f7a3b505f2b03fd3189d07548a1143d736cb5d472b016a9f0b5c95d0a1fbf"
        );
        proof[2] = bytes32(
            hex"e94c52de115f43e549267af35e5bf6a7cb0f9d35b3a7eb3cad31b25cd19065af"
        );

        // Expect revert
        vm.expectRevert("Invalid merkle proof");

        // Call the function
        vm.deal(buyer, presalePrice);
        vm.broadcast(buyer);
        presale.presale{value: presalePrice}(proof, 2);
    }

    /*
     * @dev Tests the tokenURI method of the NFTPresale contract.
     */
    function testTokenURI() public {
        // Set up
        address buyer = vm.addr(1);
        vm.deal(buyer, price);
        vm.broadcast(buyer);
        presale.mint{value: price}();
        uint256 tokenId = presale.totalSupply();

        string memory expectedUri = string(
            abi.encodePacked(
                BASE_URI,
                (tokenId % METADATA_COUNT).toString(),
                ".json"
            )
        );

        // Verify the effects
        assertEq(presale.tokenURI(tokenId), expectedUri);
    }

    /*
     * @dev Tests the royaltyInfo method of the NFTPresale contract.
     */
    function testRoyaltyInfo() public {
        // Set up
        address buyer = vm.addr(1);
        vm.deal(buyer, price);
        vm.broadcast(buyer);
        presale.mint{value: price}();

        // Call the function
        (address owner, uint256 royaltyAmount) = presale.royaltyInfo(1, price);

        // Verify the effects
        assertEq(owner, buyer);
        assertEq(royaltyAmount, 25000);
    }

    /*
     * @dev Tests the withdraw method of the NFTPresale contract.
     */
    function testWithdraw() public {
        // Set up
        address receiverFunds = vm.addr(2);
        uint256 receiverBalance = address(receiverFunds).balance;
        uint256 contractBalance = address(this).balance;
        address buyer = vm.addr(1);
        vm.deal(buyer, price);
        vm.broadcast(buyer);
        presale.mint{value: price}();

        // Call the function
        presale.withdraw(receiverFunds);

        // Verify the effects
        assertEq(address(receiverFunds).balance, receiverBalance + price);
        assertEq(address(this).balance, contractBalance);
    }

    /**
     * @dev This function test NFTPresale contract withdraw method reverts when the caller is not the owner.
     */
    function testRevert_WithdrawNotAnOwner() public {
        // Set up
        address receiverFunds = vm.addr(2);
        uint256 receiverBalance = address(receiverFunds).balance;
        uint256 contractBalance = address(this).balance;
        address buyer = vm.addr(1);
        vm.deal(buyer, price);
        vm.broadcast(buyer);
        presale.mint{value: price}();

        // Expect revert
        vm.expectRevert("Ownable: caller is not the owner");

        // Call the function
        vm.prank(receiverFunds);
        presale.withdraw(receiverFunds);

        // Verify the effects
        assertEq(address(receiverFunds).balance, receiverBalance);
        assertEq(address(this).balance, contractBalance);
    }

    /*
     * @dev Tests that the `transferOwnership` function reverts when the caller is not the new owner.
     */
    function testRevert_TransferOwnershipNotANewOwner() public {
        // Set up
        address newOwner = vm.addr(1);
        presale.transferOwnership(newOwner);
        assertEq(presale.owner(), address(this));

        // Expect revert
        vm.expectRevert("Only the new owner can accept ownership");

        // Call the function
        vm.prank(vm.addr(2));
        presale.acceptOwnership();

        // Verify the effects
        assertEq(presale.owner(), address(this));
    }

    /*
     * @dev Tests that the `transferOwnership` function reverts when the new owner address is a zero address.
     */
    function testRevert_TransferOwnershipZeroAddress() public {
        // Expect revert
        vm.expectRevert("New owner address cannot be zero");

        // Call the function
        presale.transferOwnership(address(0));

        // Verify the effects
        assertEq(presale.owner(), address(this));
    }

    /*
     * @dev Tests that the `mint` function reverts when there are insufficient funds.
     */
    function testRevert_MintInsufficientFunds() public {
        // Set up
        address buyer = vm.addr(1);
        vm.deal(buyer, price);
        vm.broadcast(buyer);

        // Expect revert
        vm.expectRevert("Insufficient funds");

        // Call the function
        presale.mint{value: price - 1}();

        // Verify the effects
        assertEq(presale.totalSupply(), 0);
        assertEq(presale.balanceOf(buyer), 0);
    }

    /*
     * @dev Tests that the `presale` function reverts when there are insufficient funds.
     */
    function testRevert_PresaleInsufficientFunds() public {
        // Set up
        address buyer = address(0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB);
        bytes32[] memory proof = new bytes32[](3);
        proof[0] = bytes32(
            hex"bd555f4c1d283441246e3b8081e994217b8109898aa1ac2c652b4b5e1d745d4d"
        );
        proof[1] = bytes32(
            hex"2a7f7a3b505f2b03fd3189d07548a1143d736cb5d472b016a9f0b5c95d0a1fbf"
        );
        proof[2] = bytes32(
            hex"e94c52de115f43e549267af35e5bf6a7cb0f9d35b3a7eb3cad31b25cd19065af"
        );

        // Expect revert
        vm.expectRevert("Insufficient funds");

        // Call the function
        vm.deal(buyer, presalePrice);
        vm.broadcast(buyer);
        presale.presale{value: presalePrice - 1}(proof, 3);

        // Verify the effects
        assertEq(presale.totalSupply(), 0);
        assertEq(presale.balanceOf(buyer), 0);
    }

    /*
     * @dev Tests that the `presale` function reverts when the NFT has already been minted.
     */
    function testRevert_PresaleAlreadyMinted() public {
        // Set up
        address buyer = address(0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB);
        bytes32[] memory proof = new bytes32[](3);
        proof[0] = bytes32(
            hex"bd555f4c1d283441246e3b8081e994217b8109898aa1ac2c652b4b5e1d745d4d"
        );
        proof[1] = bytes32(
            hex"2a7f7a3b505f2b03fd3189d07548a1143d736cb5d472b016a9f0b5c95d0a1fbf"
        );
        proof[2] = bytes32(
            hex"e94c52de115f43e549267af35e5bf6a7cb0f9d35b3a7eb3cad31b25cd19065af"
        );
        vm.deal(buyer, 2 * presalePrice);
        vm.prank(buyer);
        presale.presale{value: presalePrice}(proof, 3);

        // Expect revert
        vm.expectRevert("Already minted");

        // Call the function
        vm.prank(buyer);
        presale.presale{value: presalePrice}(proof, 3);

        // Verify the effects
        assertEq(presale.totalSupply(), 1);
        assertEq(presale.balanceOf(buyer), 1);
    }

    /*
     * @dev Tests that the `tokenURI` function reverts when the token does not exist.
     */
    function testRevert_TokenURINotExists() public {
        // Set up
        address buyer = vm.addr(1);
        vm.deal(buyer, price);
        vm.broadcast(buyer);
        presale.mint{value: price}();

        // Expect revert
        vm.expectRevert("Token does not exist");

        // Verify the effects
        string memory ret = presale.tokenURI(2);

        // Verify the effects
        assertEq(ret, "");
    }
}
