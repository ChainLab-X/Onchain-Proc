# Onchain-Proc

An open-source platform for Ethereum-based projects. Explore, contribute, and showcase smart contracts and decentralized applications built on Ethereum and EVM-compatible chains.

## 🌟 About

Onchain-Proc is a community-driven repository where developers can:
- **Submit** their Ethereum smart contract projects
- **Explore** innovative blockchain applications
- **Contribute** to open-source Web3 projects
- **Learn** from real-world implementations

## 📁 Repository Structure

```
Onchain-Proc/
├── cohort-xii/          # Smart Contract Projects (125+ projects)
│   └── submissions/     # Community-submitted smart contracts
└── cohort-xiii/         # Frontend Applications
    └── Web3bridge-Web3-Cohort-XIII/  # Decentralized app interfaces
```

## 🚀 Getting Started

### For Smart Contract Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/VaultsX/Onchain-Proc.git
   cd Onchain-Proc
   ```

2. **Set up your environment**
   ```bash
   # Copy the example environment file
   cp .env.example .env
   
   # Add your private key and RPC URLs
   nano .env
   ```

3. **Compile contracts** (using the root Hardhat config)
   ```bash
   npx hardhat compile
   ```

4. **Deploy to your preferred network**
   ```bash
   npx hardhat run scripts/deploy.js --network <network-name>
   ```

### Supported Networks

The `hardhat.config.ts` supports deployment to:
- **Ethereum**: Mainnet, Sepolia
- **Base**: Mainnet, Sepolia
- **Arbitrum**: Mainnet, Sepolia
- **Optimism**: Mainnet, Sepolia
- **Polygon**: Mainnet, Amoy
- **Scroll**: Mainnet, Sepolia
- **Celo**: Mainnet, Alfajores
- And more...

## 🤝 Contributing

We welcome contributions from developers of all skill levels!

### Submit Your Project

1. **Fork** this repository
2. **Create** a new folder in `cohort-xii/submissions/` for smart contracts or `cohort-xiii/Web3bridge-Web3-Cohort-XIII/` for frontends
3. **Add** your project files with clear documentation
4. **Submit** a pull request with a description of your project

### Project Guidelines

- Include a README in your project folder
- Add comments to your code
- Follow Solidity best practices for smart contracts
- Test your code before submitting

## 🔧 Environment Setup

Create a `.env` file based on `.env.example`:

```env
# Your wallet private key (NEVER commit this!)
PRIVATE_KEY=your_private_key_here

# RPC URLs for different networks
BASE_SEPOLIA_RPC_URL=https://sepolia.base.org
BASE_RPC_URL=https://mainnet.base.org

# API key for contract verification
ETHERSCAN_API_KEY=your_etherscan_api_key_here
```

**⚠️ Security Note**: Never commit your `.env` file or private keys to version control!

## 📚 Explore Projects

Browse through `cohort-xii/submissions/` to discover:
- DeFi protocols
- NFT contracts
- DAO implementations
- Token standards (ERC-20, ERC-721, ERC-4626)
- Governance systems
- And much more!

## 🌐 Community

- **GitHub**: [VaultsX/Onchain-Proc](https://github.com/VaultsX/Onchain-Proc)
- **Issues**: Report bugs or request features
- **Discussions**: Share ideas and get help

## 📜 License

This repository and its projects are open-source. Individual projects may have their own licenses - please check each project's README for details.

## 🙏 Acknowledgments

Thanks to all contributors who have shared their projects and helped build this community resource!

---

**Start exploring, learning, and contributing to the future of decentralized applications!**
