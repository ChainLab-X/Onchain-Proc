// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ParkingToken
 * @dev ERC20 token for tokenized parking reservations
 * @notice Drivers can purchase parking tokens to reserve spots and prevent double bookings
 */
contract ParkingToken is ERC20, Ownable {
    
    // Token price in wei (can be updated by owner)
    uint256 public tokenPrice;
    
    // Mapping to track token usage for reservations
    mapping(address => mapping(uint256 => bool)) public tokenUsedForReservation;
    
    // Events
    event TokensPurchased(address indexed buyer, uint256 amount, uint256 totalCost);
    event TokensRedeemed(address indexed user, uint256 amount);
    event TokenPriceUpdated(uint256 oldPrice, uint256 newPrice);
    
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialPrice
    ) ERC20(name, symbol) Ownable(msg.sender) {
        require(initialPrice > 0, "Price must be greater than 0");
        tokenPrice = initialPrice;
    }

    /**
     * @notice Purchase parking tokens with ETH
     * @param amount Number of tokens to purchase
     */
    function purchaseTokens(uint256 amount) external payable {
        require(amount > 0, "Amount must be greater than 0");
        
        uint256 totalCost = amount * tokenPrice;
        require(msg.value >= totalCost, "Insufficient payment");
        
        // Mint tokens to buyer
        _mint(msg.sender, amount * 10**decimals());
        
        // Refund excess payment
        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost);
        }
        
        emit TokensPurchased(msg.sender, amount, totalCost);
    }

    /**
     * @notice Redeem tokens for ETH (burn tokens)
     * @param amount Number of tokens to redeem
     */
    function redeemTokens(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(balanceOf(msg.sender) >= amount * 10**decimals(), "Insufficient balance");
        
        uint256 redeemValue = amount * tokenPrice;
        require(address(this).balance >= redeemValue, "Insufficient contract balance");
        
        // Burn tokens
        _burn(msg.sender, amount * 10**decimals());
        
        // Transfer ETH to user
        payable(msg.sender).transfer(redeemValue);
        
        emit TokensRedeemed(msg.sender, amount);
    }

    /**
     * @notice Update token price (only owner)
     * @param newPrice New price per token in wei
     */
    function updateTokenPrice(uint256 newPrice) external onlyOwner {
        require(newPrice > 0, "Price must be greater than 0");
        uint256 oldPrice = tokenPrice;
        tokenPrice = newPrice;
        emit TokenPriceUpdated(oldPrice, newPrice);
    }

    /**
     * @notice Mark tokens as used for a reservation
     * @param user Address of the user
     * @param reservationId ID of the reservation
     */
    function markTokenUsed(address user, uint256 reservationId) external onlyOwner {
        tokenUsedForReservation[user][reservationId] = true;
    }

    /**
     * @notice Check if tokens were used for a reservation
     * @param user Address of the user
     * @param reservationId ID of the reservation
     */
    function isTokenUsed(address user, uint256 reservationId) external view returns (bool) {
        return tokenUsedForReservation[user][reservationId];
    }

    /**
     * @notice Withdraw contract balance (only owner)
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        payable(owner()).transfer(balance);
    }

    /**
     * @notice Get token price
     */
    function getTokenPrice() external view returns (uint256) {
        return tokenPrice;
    }
}
