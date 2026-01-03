# Urban Parking dApp - Smart Contracts

## 🚗 Overview

A decentralized application for urban traffic and parking management, addressing pain points in busy markets like Computer Village, Idumota, and Marina in Lagos, Nigeria.

## 🎯 Problem Statement

### Pain Points
- Limited parking in busy markets
- No real-time availability information
- Parking fee disputes and lack of transparency
- Double bookings and reservation conflicts
- Lack of community input on parking rules and fees

## 🔧 Solution Components

### 1. Decentralized Parking Market (`ParkingMarket.sol`)
A dApp where parking owners can list spaces with real-time availability and accept payments in crypto/stablecoins.

**Features:**
- List parking spaces with location, description, and pricing
- Real-time availability tracking
- Secure reservation system
- Automated payment distribution (owner + platform fee)
- Multi-slot support for parking lots

### 2. Tokenized Reservation System (`ParkingToken.sol`)
ERC20 tokens that drivers can purchase to reserve spots and prevent double bookings.

**Features:**
- Purchase parking tokens with ETH
- Redeem tokens back to ETH
- Token-based reservation system
- Prevents double bookings through token locking

### 3. DAO-Run Parking Communities (`ParkingDAO.sol`)
Decentralized governance where drivers vote on parking rules, fees, and penalties.

**Features:**
- Proposal creation for rule changes, fee adjustments, and penalties
- Weighted voting based on participation
- Quorum and threshold requirements
- Transparent decision-making process

## 📋 Smart Contracts

| Contract | Description | Key Functions |
|----------|-------------|---------------|
| `ParkingMarket.sol` | Main marketplace contract | `listSpace`, `reserveSpace`, `completeReservation` |
| `ParkingToken.sol` | ERC20 token for reservations | `purchaseTokens`, `redeemTokens` |
| `ParkingDAO.sol` | Governance contract | `createProposal`, `vote`, `executeProposal` |

## 🚀 Getting Started

### Prerequisites
- Node.js >= 16.x
- Hardhat
- MetaMask or compatible Web3 wallet

### Installation

```bash
# Install dependencies
npm install

# Compile contracts
npx hardhat compile

# Run tests
npx hardhat test

# Deploy to testnet
npx hardhat run scripts/deploy.js --network <network-name>
```

## 🔐 Security Features

- **ReentrancyGuard**: Protection against reentrancy attacks
- **Access Control**: Role-based permissions for DAO governance
- **Ownable**: Secure admin functions
- **Input Validation**: Comprehensive checks on all user inputs
- **Safe Math**: Using Solidity 0.8.x built-in overflow protection

## 🌐 Supported Networks

- Ethereum Mainnet
- Polygon
- Base
- Arbitrum
- Optimism
- Lisk Sepolia (Testnet)

## 📊 Contract Architecture

```
┌─────────────────────┐
│   ParkingMarket     │
│  (Main Contract)    │
└──────────┬──────────┘
           │
           ├──────────────────┐
           │                  │
┌──────────▼──────────┐  ┌───▼──────────┐
│   ParkingToken      │  │  ParkingDAO  │
│   (ERC20 Token)     │  │ (Governance) │
└─────────────────────┘  └──────────────┘
```

## 💡 Usage Examples

### For Parking Owners

```solidity
// List a parking space
uint256 spaceId = parkingMarket.listSpace(
    "Computer Village, Ikeja",
    "Secure parking with 24/7 security",
    0.001 ether, // Price per hour
    10 // Total slots
);
```

### For Drivers

```solidity
// Reserve a parking space
uint256 reservationId = parkingMarket.reserveSpace{value: 0.005 ether}(
    spaceId,
    block.timestamp + 1 hours, // Start time
    5 // Duration in hours
);
```

### For DAO Participants

```solidity
// Create a proposal to change parking fees
uint256 proposalId = parkingDAO.createProposal(
    ProposalType.FeeChange,
    "Reduce parking fees by 10%",
    "To make parking more affordable for daily commuters",
    0.0009 ether // New fee
);

// Vote on proposal
parkingDAO.vote(proposalId, true); // true = support
```

## 🧪 Testing

```bash
# Run all tests
npx hardhat test

# Run specific test file
npx hardhat test test/ParkingMarket.test.js

# Run with coverage
npx hardhat coverage
```

## 📝 License

MIT License

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Contact

For questions or support, please open an issue in the repository.

---

**Built for ChainLab-X Onchain-Proc** | Solving real-world problems with blockchain technology
