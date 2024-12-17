// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTWithUSDC is ERC721, Ownable {
    using SafeERC20 for IERC20;

    // USDC contract
    IERC20 public immutable usdc;

    // Price in USDC (1 USDC = 1_000_000 because USDC has 6 decimals)
    uint256 public constant MINT_PRICE = 1_000_000;

    // Token ID counter
    uint256 private _tokenIdCounter;

    // Events
    event NFTMinted(
        address indexed minter,
        address indexed recipient,
        uint256 indexed tokenId
    );
    event PaymentReceived(address indexed from, uint256 amount);
    event USDCWithdrawn(address indexed to, uint256 amount);

    constructor(
        address usdcAddress
    ) ERC721("MyNFT", "MNFT") Ownable(msg.sender) {
        require(usdcAddress != address(0), "Invalid USDC address");
        usdc = IERC20(usdcAddress);
    }

    function mint(address recipient) external {
        // Input validation
        require(recipient != address(0), "Cannot mint to zero address");

        // Check USDC allowance
        require(
            usdc.allowance(msg.sender, address(this)) >= MINT_PRICE,
            "Insufficient USDC allowance"
        );

        // Transfer USDC first (CEI pattern)
        usdc.safeTransferFrom(msg.sender, owner(), MINT_PRICE);
        emit PaymentReceived(msg.sender, MINT_PRICE);

        // Mint NFT
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _safeMint(recipient, tokenId);
        emit NFTMinted(msg.sender, recipient, tokenId);
    }

    function withdraw() external onlyOwner {
        uint256 balance = usdc.balanceOf(address(this));
        require(balance > 0, "No USDC to withdraw");

        usdc.safeTransfer(owner(), balance);
        emit USDCWithdrawn(owner(), balance);
    }

    // View function to get mint price
    function getMintPrice() external pure returns (uint256) {
        return MINT_PRICE;
    }
}
