// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTSwap {
    using SafeERC20 for IERC20;

    IERC20 public immutable USDC;
    IERC721 public immutable nftContract;
    uint256 public immutable nftId;
    uint256 public immutable price;
    address public immutable seller;
    address public immutable buyer;

    bool public isSwapExecuted;

    event SwapExecuted(
        address buyer,
        address seller,
        uint256 nftId,
        uint256 price
    );

    constructor(
        address _usdc,
        address _nftContract,
        uint256 _nftId,
        uint256 _price,
        address _seller,
        address _buyer
    ) {
        require(_usdc != address(0), "Invalid USDC address");
        require(_nftContract != address(0), "Invalid NFT contract address");
        require(_seller != address(0), "Invalid seller address");
        require(_buyer != address(0), "Invalid buyer address");
        require(_price > 0, "Price must be greater than 0");
        require(_seller != _buyer, "Seller and buyer cannot be the same");

        USDC = IERC20(_usdc);
        nftContract = IERC721(_nftContract);
        nftId = _nftId;
        price = _price;
        seller = _seller;
        buyer = _buyer;

        // Verify the NFT contract is valid
        try nftContract.supportsInterface(0x80ac58cd) returns (bool supported) {
            require(supported, "Not an ERC721 contract");
        } catch {
            revert("Invalid NFT contract");
        }
    }

    function executeSwap() external {
        require(!isSwapExecuted, "Swap already executed");
        require(msg.sender == buyer, "Only buyer can execute");
        require(
            nftContract.ownerOf(nftId) == seller,
            "Seller does not own NFT"
        );
        require(
            nftContract.isApprovedForAll(seller, address(this)) ||
                nftContract.getApproved(nftId) == address(this),
            "NFT not approved"
        );

        isSwapExecuted = true;

        USDC.safeTransferFrom(buyer, seller, price);
        nftContract.transferFrom(seller, buyer, nftId);

        emit SwapExecuted(buyer, seller, nftId, price);
    }
}
