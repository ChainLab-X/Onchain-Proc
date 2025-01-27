# VaultsIQ — Smart Contracts

Solidity smart contracts for VaultsIQ - a decentralized vault platform enabling users to create multiple ERC-4626 compliant vaults for automated yield generation. Deployed on Base Sepolia testnet.

## Overview

VaultsIQ is a comprehensive DeFi platform that allows users to:

- **Create Multiple Vaults**: Each user can create multiple personal ERC-4626 compliant vaults
- **Automated Yield Generation**: Deploy assets to DeFi protocols (Aave, Compound, Uniswap) automatically
- **ERC-4626 Standard**: Industry-standard tokenized vault interface for maximum interoperability
- **Share-Based Ownership**: Transferable ERC-20 vault shares representing ownership
- **Protocol Allocations**: Configure how assets are distributed across different DeFi protocols


VaultsIQ smart contracts implement:

### VaultFactory Contract

- **Multi-vault creation** for registered users
- **User registration system** with username and bio
- **Protocol address management** (Aave, Compound, Uniswap, WETH)
- **Admin system** for protocol configuration
- **Vault tracking** and ownership management

### UserVault Contract (ERC-4626)

- **ERC-4626 standard compliance** for tokenized vaults
- **ERC-20 share tokens** representing vault ownership
- **Deposit/Withdraw/Mint/Redeem** operations
- **Protocol integration** for yield generation
- **Allocation management** across DeFi protocols
- **Pause/unpause** functionality

Built with Solidity, Hardhat, and deployed on Base Sepolia testnet.

## Tech Stack

- **Language:** Solidity ^0.8.20
- **Framework:** Hardhat
- **Testing:** Hardhat Test Suite, Chai
- **Network:** Base Sepolia Testnet
- **Chain ID:** 84532

## Quick Start

```bash
# Install dependencies
npm install

# Compile contracts
npx hardhat compile

# Run tests
npx hardhat test

# Deploy to Base Sepolia
npx hardhat run scripts/deploy.js --network baseSepolia
```

## Project Structure

```
vaultsiq-smartcontracts/
├── contracts/
│   ├── VaultFactory.sol          # Factory contract for vault deployment
│   ├── UserVault.sol             # ERC-4626 compliant vault contract
│   ├── interfaces/
│   │   ├── IERC4626.sol          # ERC-4626 interface
│   │   ├── IERC20.sol            # ERC-20 interface
│   │   └── IProtocol.sol         # Protocol interface
│   └── libraries/
│       └── VaultMath.sol         # Math utilities for vault calculations
├── scripts/
│   ├── deploy.js                 # Deployment script
│   ├── verify.js                 # Contract verification script
│   └── initialize.js             # Contract initialization script
├── test/
│   ├── VaultFactory.test.js      # Factory contract tests
│   ├── UserVault.test.js         # Vault contract tests
│   └── integration.test.js       # Integration tests
├── hardhat.config.js             # Hardhat configuration
└── package.json                  # Dependencies
```

## Contract Architecture

### VaultFactory.sol

**Purpose:** Central factory managing vault creation, user registration, and protocol configuration.

**Key Functions:**
- `registerUser(string username, string bio)` - Register user profile
- `createVault(address asset)` - Create new ERC-4626 vault
- `getUserVaults(address user)` - Get all vaults for a user
- `setAaveAddress(address)` - Admin: Set Aave protocol address
- `addAdmin(address)` - Admin: Add new admin

**Events:**
- `VaultCreated(address indexed owner, address indexed vault, uint256 timestamp)`
- `UserRegistered(address indexed user, uint256 timestamp)`

### UserVault.sol

**Purpose:** Individual ERC-4626 compliant vault with DeFi protocol integration.

**Key Functions (ERC-4626):**
- `deposit(uint256 assets, address receiver)` - Deposit assets, receive shares
- `withdraw(uint256 assets, address receiver, address owner)` - Withdraw assets
- `mint(uint256 shares, address receiver)` - Mint shares for assets
- `redeem(uint256 shares, address receiver, address owner)` - Redeem shares
- `totalAssets()` - Total assets managed by vault
- `convertToShares(uint256 assets)` - Convert assets to shares
- `convertToAssets(uint256 shares)` - Convert shares to assets

**Key Functions (Vault Management):**
- `setProtocolAllocation(string protocol, uint256 amount)` - Configure allocation
- `deployToAave(uint256 amount)` - Deploy assets to Aave
- `deployToCompound(uint256 amount)` - Deploy assets to Compound
- `pause()` / `unpause()` - Emergency controls

**Events:**
- `Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares)`
- `Withdraw(address indexed sender, address indexed receiver, address indexed owner, uint256 assets, uint256 shares)`

## Contributing

We welcome contributions! To get started:

1. **Pick an issue** from [`ISSUES.md`](./ISSUES.md)
2. **Create a branch** using the issue number: `issue/<number>-short-description`
3. **Implement your changes** following the issue's acceptance criteria
4. **Write tests** for your changes
5. **Submit a PR** with the issue number in the title/description

When pushing your changes, include the issue number or title in your commit messages.

## Environment Variables

Create a `.env` file:

```env
PRIVATE_KEY=your_private_key
BASE_SEPOLIA_RPC_URL=https://sepolia.base.org
ETHERSCAN_API_KEY=your_etherscan_api_key
```

**Note:** Never commit your private key or `.env` file to version control!

## Network Configuration

### Base Sepolia Testnet

- **Chain ID:** 84532
- **RPC URL:** `https://sepolia.base.org`
- **Explorer:** [Base Sepolia Explorer](https://sepolia.basescan.org/)
- **Faucet:** [Base Sepolia Faucet](https://www.coinbase.com/faucets/base-ethereum-goerli-faucet)

## Deployment

### Deploy VaultFactory

```bash
npx hardhat run scripts/deploy.js --network baseSepolia
```

### Initialize VaultFactory

```bash
npx hardhat run scripts/initialize.js --network baseSepolia
```

### Verify Contracts

```bash
npx hardhat verify --network baseSepolia <CONTRACT_ADDRESS> <CONSTRUCTOR_ARGS>
```

## Testing

```bash
# Run all tests
npx hardhat test

# Run specific test file
npx hardhat test test/UserVault.test.js

# Run tests with gas reporting
REPORT_GAS=true npx hardhat test

# Coverage report
npx hardhat coverage
```

## Security

- All contracts follow best practices
- Access control implemented for admin functions
- Reentrancy guards on critical functions
- Input validation on all user inputs
- Comprehensive test coverage

**Note:** Contracts should be audited before mainnet deployment.

## License

MIT License - see LICENSE file for details.
