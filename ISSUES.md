# Smart Contracts Issues

This file contains all GitHub issues for the VaultsIQ smart contracts. Each issue is ready to be copied into GitHub.

## ✅ Completed Issues

### Issue #1: Project Setup & Hardhat Configuration

**Status:** ✅ COMPLETED  

**Labels:** `smart-contracts`, `infrastructure`, `setup`  

**Priority:** HIGH

**Description:**

Set up Hardhat project with proper configuration for Base Sepolia testnet. Configure compiler settings, network settings, and necessary plugins.

**Acceptance Criteria:**

- [x] Initialize npm project with `package.json`
- [x] Install Hardhat and dependencies
- [x] Configure `hardhat.config.js`:
  - [x] Solidity compiler version (^0.8.20)
  - [x] Base Sepolia network configuration
  - [x] Gas optimization settings
  - [x] Etherscan verification plugin
- [x] Create project folder structure:
  - [x] `contracts/` directory
  - [x] `scripts/` directory
  - [x] `test/` directory
- [x] Set up environment variables file (`.env.example`)
- [x] Add `.gitignore` for artifacts, cache, node_modules, .env
- [x] Create basic README.md structure

**Implementation Notes:**

- Use Hardhat version ^2.19.0 or latest
- Install: `@nomicfoundation/hardhat-toolbox`
- Configure Base Sepolia RPC: `https://sepolia.base.org`
- Chain ID: 84532
- Solidity optimizer enabled with 200 runs

**Completed:** All acceptance criteria met. Project structure created, dependencies installed, and Hardhat configured for Base Sepolia testnet.

---

### Issue #2: ERC-4626 Interface Implementation

**Status:** ✅ COMPLETED  

**Labels:** `smart-contracts`, `standard`, `erc4626`  

**Priority:** HIGH

**Description:**

Implement the ERC-4626 interface (`IERC4626.sol`) in the contracts directory. This is the standard interface that all vault contracts must implement.

**Acceptance Criteria:**

- [x] Create `contracts/interfaces/IERC4626.sol`
- [x] Implement all required ERC-4626 functions:
  - [x] `asset()` - Returns the address of the underlying asset
  - [x] `totalAssets()` - Returns total assets managed
  - [x] `convertToShares(uint256 assets)` - Assets to shares conversion
  - [x] `convertToAssets(uint256 shares)` - Shares to assets conversion
  - [x] `maxDeposit(address)` - Maximum deposit for receiver
  - [x] `maxMint(address)` - Maximum shares to mint
  - [x] `maxWithdraw(address owner)` - Maximum withdraw for owner
  - [x] `maxRedeem(address owner)` - Maximum shares to redeem
  - [x] `previewDeposit(uint256 assets)` - Preview deposit
  - [x] `previewMint(uint256 shares)` - Preview mint
  - [x] `previewWithdraw(uint256 assets)` - Preview withdraw
  - [x] `previewRedeem(uint256 shares)` - Preview redeem
- [x] Implement all required ERC-4626 events:
  - [x] `Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares)`
  - [x] `Withdraw(address indexed sender, address indexed receiver, address indexed owner, uint256 assets, uint256 shares)`
- [x] Follow ERC-4626 standard specification exactly
- [x] Add NatSpec documentation for all functions

**Implementation Notes:**

- Reference: [EIP-4626 Specification](https://eips.ethereum.org/EIPS/eip-4626)
- Interface should extend IERC20 for share tokens
- All functions must match standard signatures exactly
- Use proper event indexing

**Completed:** All acceptance criteria met. IERC4626 interface created with all required functions, events, and comprehensive NatSpec documentation. Interface extends IERC20 from OpenZeppelin and follows EIP-4626 specification exactly.

---

## ❌ Pending Issues

### Issue #3: UserVault Contract — Core ERC-4626 Implementation

**Status:** ✅ COMPLETED  

**Labels:** `smart-contracts`, `feature`, `erc4626`, `vault`  

**Priority:** HIGH

**Description:**

Implement the core UserVault contract that extends ERC-4626 standard. This contract handles deposits, withdrawals, share calculations, and basic vault functionality.

**Acceptance Criteria:**

- [x] Create `contracts/UserVault.sol`
- [x] Implement ERC-4626 interface
- [x] Extend ERC20 for vault shares
- [x] Core functionality:
  - [x] `deposit(uint256 assets, address receiver)` - Deposit assets, mint shares
  - [x] `withdraw(uint256 assets, address receiver, address owner)` - Withdraw assets, burn shares
  - [x] `mint(uint256 shares, address receiver)` - Mint shares for assets
  - [x] `redeem(uint256 shares, address receiver, address owner)` - Redeem shares for assets
- [x] Share calculation logic:
  - [x] First deposit: 1:1 ratio (assets = shares)
  - [x] Subsequent deposits: proportional based on total assets/shares
  - [x] Handle edge cases (zero assets, zero shares)
- [x] Asset management:
  - [x] Store underlying asset address
  - [x] Track total assets and total shares
  - [x] Transfer assets from/to users
- [x] Access control:
  - [x] Owner-only functions
  - [x] Proper ownership checks
- [x] Events emitted for all operations
- [x] NatSpec documentation

**Implementation Notes:**

- Use OpenZeppelin's ERC20 implementation for shares
- Implement proper rounding in share calculations (round down for safety)
- Handle first deposit edge case correctly
- Use safe math (Solidity 0.8+ has built-in overflow protection)

---

### Issue #4: VaultFactory Contract — User Registration

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `feature`, `factory`  

**Priority:** HIGH

**Description:**

Implement user registration functionality in VaultFactory contract. Users must register with a username and bio before creating vaults.

**Acceptance Criteria:**

- [ ] Create `contracts/VaultFactory.sol` (or add to existing)
- [ ] User registration:
  - [ ] `registerUser(string username, string bio)` function
  - [ ] Username validation (max 20 characters)
  - [ ] Bio validation (max 30 characters)
  - [ ] Prevent duplicate registration
  - [ ] Store registration timestamp
- [ ] Storage structure:
  - [ ] `mapping(address => bool) registeredUsers`
  - [ ] `mapping(address => string) userUsernames`
  - [ ] `mapping(address => string) userBios`
  - [ ] `mapping(address => uint256) userRegistrationTimestamps`
- [ ] View functions:
  - [ ] `isUserRegistered(address user) returns (bool)`
  - [ ] `getUserInfo(address user) returns (string, string, uint256)`
- [ ] Event: `UserRegistered(address indexed user, uint256 timestamp)`
- [ ] Input validation and error messages
- [ ] Gas optimization considerations

**Implementation Notes:**

- Consider storing strings as bytes32 hashes for gas optimization
- Or store strings directly if gas is not a primary concern
- Add proper require statements with clear error messages
- Consider using custom errors for gas efficiency

---

### Issue #5: VaultFactory Contract — Vault Creation

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `feature`, `factory`, `vault`  

**Priority:** HIGH

**Description:**

Implement vault creation functionality in VaultFactory. Registered users can create multiple ERC-4626 vaults. Factory should deploy new UserVault contracts.

**Acceptance Criteria:**

- [ ] Vault creation function:
  - [ ] `createVault(address asset) returns (address)` - Creates new vault
  - [ ] Check user is registered
  - [ ] Deploy new UserVault contract
  - [ ] Initialize vault with owner, asset, factory
  - [ ] Track vault in user's vault list
- [ ] Storage structure:
  - [ ] `mapping(address => address[]) userVaults` - User's vault addresses
  - [ ] `mapping(address => address) vaultOwners` - Vault owner mapping
  - [ ] `mapping(address => uint256) vaultCreatedAt` - Creation timestamps
  - [ ] `uint256 totalVaults` - Total vaults created
- [ ] View functions:
  - [ ] `getUserVaults(address user) returns (address[])`
  - [ ] `getVaultOwner(address vault) returns (address)`
  - [ ] `getTotalVaults() returns (uint256)`
- [ ] Event: `VaultCreated(address indexed owner, address indexed vault, address indexed asset, uint256 timestamp)`
- [ ] Gas optimization for vault deployment

**Implementation Notes:**

- Use `new UserVault()` to deploy contracts
- Consider using CREATE2 for deterministic addresses (optional)
- Pass factory address to vault for protocol address lookup
- Track all vaults for platform statistics

---

### Issue #6: VaultFactory Contract — Admin System

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `feature`, `factory`, `admin`  

**Priority:** MEDIUM

**Description:**

Implement admin system in VaultFactory for managing protocol addresses and platform configuration. Deployer should be initial admin.

**Acceptance Criteria:**

- [ ] Admin management:
  - [ ] `addAdmin(address newAdmin)` - Add admin (admin only)
  - [ ] `removeAdmin(address admin)` - Remove admin (admin only)
  - [ ] Deployer is initial admin (in constructor)
  - [ ] Cannot remove deployer admin
- [ ] Storage structure:
  - [ ] `address deployerAdmin` - Deployer address
  - [ ] `mapping(address => bool) admins` - Admin addresses
  - [ ] `uint256 adminCount` - Total admin count
- [ ] Modifier: `onlyAdmin()` for access control
- [ ] View functions:
  - [ ] `isAdmin(address) returns (bool)`
  - [ ] `getAdminCount() returns (uint256)`
- [ ] Events:
  - [ ] `AdminAdded(address indexed admin, address indexed addedBy)`
  - [ ] `AdminRemoved(address indexed admin, address indexed removedBy)`
- [ ] Proper access control checks

**Implementation Notes:**

- Use OpenZeppelin's Ownable or implement custom access control
- Consider multi-sig for admin operations (future enhancement)
- Prevent removing the last admin or deployer

---

### Issue #7: VaultFactory Contract — Protocol Address Management

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `feature`, `factory`, `admin`  

**Priority:** HIGH

**Description:**

Implement protocol address management in VaultFactory. Admins can set addresses for DeFi protocols (Aave, Compound, Uniswap, WETH) that vaults will interact with.

**Acceptance Criteria:**

- [ ] Protocol address setters (admin only):
  - [ ] `setAaveAddress(address aaveAddress)`
  - [ ] `setCompoundAddress(address compoundAddress)`
  - [ ] `setUniswapAddress(address uniswapAddress)`
  - [ ] `setWETHAddress(address wethAddress)`
- [ ] Storage structure:
  - [ ] `address aaveLendingPool`
  - [ ] `address compoundComptroller`
  - [ ] `address uniswapRouter`
  - [ ] `address wethAddress`
- [ ] View functions:
  - [ ] `getAaveAddress() returns (address)`
  - [ ] `getCompoundAddress() returns (address)`
  - [ ] `getUniswapAddress() returns (address)`
  - [ ] `getWETHAddress() returns (address)`
- [ ] Events:
  - [ ] `ProtocolAddressSet(string indexed protocol, address indexed newAddress, address indexed setBy)`
- [ ] Validation (non-zero addresses)
- [ ] Admin access control

**Implementation Notes:**

- Store protocol addresses for vaults to reference
- Vaults can call factory to get protocol addresses
- Consider using a mapping for extensibility: `mapping(string => address) protocols`
- Add validation to prevent setting zero addresses

---

### Issue #8: UserVault Contract — Protocol Allocation Management

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `feature`, `vault`, `defi`  

**Priority:** HIGH

**Description:**

Implement protocol allocation management in UserVault. Owners can configure how their vault assets are allocated across different DeFi protocols.

**Acceptance Criteria:**

- [ ] Allocation management:
  - [ ] `setProtocolAllocation(string protocol, uint256 amount)` - Set allocation (owner only)
  - [ ] `getProtocolAllocation(string protocol) returns (uint256)` - Get allocation
- [ ] Storage structure:
  - [ ] `mapping(string => uint256) protocolAllocations` - Protocol name to amount
- [ ] Validation:
  - [ ] Total allocations cannot exceed total assets
  - [ ] Protocol name validation
  - [ ] Amount validation (non-negative)
- [ ] Event: `ProtocolAllocationChanged(string indexed protocol, uint256 oldAmount, uint256 newAmount)`
- [ ] View function to get all allocations
- [ ] Owner-only access control

**Implementation Notes:**

- Consider storing allocations as percentages vs absolute amounts
- Add function to get total allocated amount
- May need to track deployed amounts separately from allocations

---

### Issue #9: UserVault Contract — Aave Integration

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `feature`, `vault`, `defi`, `aave`  

**Priority:** MEDIUM

**Description:**

Implement Aave protocol integration in UserVault. Allow vault to deploy assets to Aave lending pool to earn interest.

**Acceptance Criteria:**

- [ ] Aave integration:
  - [ ] `deployToAave(uint256 amount)` - Deploy assets to Aave (owner only)
  - [ ] `withdrawFromAave(uint256 amount)` - Withdraw from Aave (owner only)
  - [ ] `getAaveBalance() returns (uint256)` - Get deposited balance
- [ ] Implementation:
  - [ ] Approve Aave to spend vault assets
  - [ ] Call Aave's `supply()` function
  - [ ] Track Aave aTokens received
  - [ ] Handle Aave withdrawals
- [ ] Safety:
  - [ ] Check protocol address is set
  - [ ] Validate amounts
  - [ ] Handle errors gracefully
- [ ] Events:
  - [ ] `ProtocolDeployed(string indexed protocol, uint256 amount)`
  - [ ] `ProtocolWithdrawn(string indexed protocol, uint256 amount)`
- [ ] Update total assets after deployment

**Implementation Notes:**

- Use Aave's IPool interface
- Need to handle aToken accounting
- Consider gas costs for protocol interactions
- Test with Aave testnet contracts

---

### Issue #10: UserVault Contract — Compound Integration

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `feature`, `vault`, `defi`, `compound`  

**Priority:** MEDIUM

**Description:**

Implement Compound protocol integration in UserVault. Allow vault to deploy assets to Compound to earn interest.

**Acceptance Criteria:**

- [ ] Compound integration:
  - [ ] `deployToCompound(uint256 amount)` - Deploy assets to Compound (owner only)
  - [ ] `withdrawFromCompound(uint256 amount)` - Withdraw from Compound (owner only)
  - [ ] `getCompoundBalance() returns (uint256)` - Get deposited balance
- [ ] Implementation:
  - [ ] Approve Compound cToken contract
  - [ ] Call Compound's `mint()` function
  - [ ] Track Compound cTokens received
  - [ ] Handle Compound redemptions
- [ ] Safety:
  - [ ] Check protocol address is set
  - [ ] Validate amounts
  - [ ] Handle errors gracefully
- [ ] Events:
  - [ ] `ProtocolDeployed(string indexed protocol, uint256 amount)`
  - [ ] `ProtocolWithdrawn(string indexed protocol, uint256 amount)`
- [ ] Update total assets after deployment

**Implementation Notes:**

- Use Compound's cToken interface
- Need to handle cToken accounting
- Compound uses exchange rate for asset conversion
- Test with Compound testnet contracts

---

### Issue #11: UserVault Contract — Pause/Unpause Functionality

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `feature`, `vault`, `security`  

**Priority:** MEDIUM

**Description:**

Implement pause/unpause functionality in UserVault for emergency stops. Only owner can pause/unpause the vault.

**Acceptance Criteria:**

- [ ] Pause functionality:
  - [ ] `pause()` - Pause vault operations (owner only)
  - [ ] `unpause()` - Resume vault operations (owner only)
- [ ] Storage:
  - [ ] `bool public paused` - Pause state
- [ ] Modifier: `whenNotPaused()` for protected functions
- [ ] Protected functions:
  - [ ] `deposit()`, `withdraw()`, `mint()`, `redeem()`
  - [ ] Protocol deployment functions
- [ ] View function:
  - [ ] `isPaused() returns (bool)`
- [ ] Events:
  - [ ] `VaultPaused(address indexed vault, address indexed pausedBy)`
  - [ ] `VaultUnpaused(address indexed vault, address indexed unpausedBy)`
- [ ] Clear error messages when paused

**Implementation Notes:**

- Use OpenZeppelin's Pausable contract or implement custom
- Consider time-locked pause for additional security
- Allow view functions to work when paused
- Test pause scenarios thoroughly

---

### Issue #12: Comprehensive Test Suite — VaultFactory

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `testing`, `factory`  

**Priority:** HIGH

**Description:**

Write comprehensive test suite for VaultFactory contract covering all functions, edge cases, and error scenarios.

**Acceptance Criteria:**

- [ ] Create `test/VaultFactory.test.js`
- [ ] Test user registration:
  - [ ] Successful registration
  - [ ] Duplicate registration fails
  - [ ] Username length validation
  - [ ] Bio length validation
  - [ ] Event emission
- [ ] Test vault creation:
  - [ ] Successful vault creation
  - [ ] Unregistered user cannot create vault
  - [ ] Vault tracking
  - [ ] Event emission
- [ ] Test admin functions:
  - [ ] Add admin (admin only)
  - [ ] Remove admin (admin only)
  - [ ] Non-admin cannot add/remove
  - [ ] Cannot remove deployer
- [ ] Test protocol address management:
  - [ ] Set protocol addresses (admin only)
  - [ ] Get protocol addresses
  - [ ] Non-admin cannot set addresses
- [ ] Test view functions:
  - [ ] `getUserVaults()`
  - [ ] `getVaultOwner()`
  - [ ] `isUserRegistered()`
- [ ] Test edge cases and error scenarios
- [ ] Test coverage > 90%

**Implementation Notes:**

- Use Hardhat's testing framework
- Use fixtures for common setup
- Test with multiple users
- Use snapshot/revert for test isolation

---

### Issue #13: Comprehensive Test Suite — UserVault

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `testing`, `vault`, `erc4626`  

**Priority:** HIGH

**Description:**

Write comprehensive test suite for UserVault contract covering ERC-4626 compliance, all functions, edge cases, and error scenarios.

**Acceptance Criteria:**

- [ ] Create `test/UserVault.test.js`
- [ ] Test ERC-4626 functions:
  - [ ] `deposit()` - First deposit, subsequent deposits
  - [ ] `withdraw()` - Withdraw assets
  - [ ] `mint()` - Mint shares
  - [ ] `redeem()` - Redeem shares
  - [ ] `convertToShares()` - Share calculations
  - [ ] `convertToAssets()` - Asset calculations
  - [ ] `totalAssets()` - Asset tracking
  - [ ] Preview functions
  - [ ] Max functions
- [ ] Test share calculations:
  - [ ] First deposit (1:1 ratio)
  - [ ] Proportional deposits
  - [ ] With yield generation
  - [ ] Edge cases (zero assets, zero shares)
- [ ] Test pause/unpause:
  - [ ] Pause functionality
  - [ ] Cannot operate when paused
  - [ ] Unpause functionality
- [ ] Test access control:
  - [ ] Owner-only functions
  - [ ] Non-owner cannot call restricted functions
- [ ] Test protocol allocations:
  - [ ] Set allocations
  - [ ] Validation
  - [ ] Event emission
- [ ] Test ERC-20 share token functionality
- [ ] Test edge cases and error scenarios
- [ ] Test coverage > 90%

**Implementation Notes:**

- Test ERC-4626 compliance thoroughly
- Use fixtures for mock assets
- Test with various amounts and scenarios
- Verify share calculations are correct

---

### Issue #14: Integration Tests

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `testing`, `integration`  

**Priority:** MEDIUM

**Description:**

Write integration tests covering the full workflow: user registration, vault creation, deposits, withdrawals, and protocol interactions.

**Acceptance Criteria:**

- [ ] Create `test/integration.test.js`
- [ ] Full workflow tests:
  - [ ] Register user → Create vault → Deposit → Withdraw
  - [ ] Multiple vault creation by same user
  - [ ] Multiple users creating vaults
  - [ ] Protocol allocation configuration
  - [ ] Share transfers between users
- [ ] Protocol integration tests:
  - [ ] Deploy to Aave (if testnet available)
  - [ ] Deploy to Compound (if testnet available)
  - [ ] Withdraw from protocols
- [ ] Edge case scenarios:
  - [ ] Large deposits/withdrawals
  - [ ] Concurrent operations
  - [ ] Error recovery
- [ ] Gas usage measurements
- [ ] Test with real ERC-20 tokens (mock tokens)

**Implementation Notes:**

- Use Hardhat's fork capability if needed
- Mock protocol contracts for testing
- Test realistic user scenarios
- Measure and optimize gas usage

---

### Issue #15: Deployment Scripts

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `deployment`, `scripts`  

**Priority:** HIGH

**Description:**

Create deployment scripts for VaultFactory and initialize it with admin setup. Prepare for Base Sepolia deployment.

**Acceptance Criteria:**

- [ ] Create `scripts/deploy.js`:
  - [ ] Deploy VaultFactory contract
  - [ ] Initialize factory (if needed)
  - [ ] Verify deployment
  - [ ] Save deployment addresses
- [ ] Create `scripts/initialize.js`:
  - [ ] Set protocol addresses (Aave, Compound, Uniswap, WETH)
  - [ ] Add additional admins (optional)
  - [ ] Verify initialization
- [ ] Create `scripts/verify.js`:
  - [ ] Verify contracts on Base Sepolia explorer
  - [ ] Support constructor arguments
- [ ] Deployment artifacts:
  - [ ] Save addresses to JSON file
  - [ ] Save ABIs
  - [ ] Deployment transaction hashes
- [ ] Environment variable support
- [ ] Error handling
- [ ] Network configuration

**Implementation Notes:**

- Use Hardhat's deployment features
- Support multiple networks
- Save deployment info for frontend integration
- Add verification delay for explorer indexing

---

### Issue #16: Gas Optimization

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `optimization`, `gas`  

**Priority:** MEDIUM

**Description:**

Optimize contract code for gas efficiency. Use gas reporting tools and implement optimizations.

**Acceptance Criteria:**

- [ ] Gas optimization techniques:
  - [ ] Pack storage variables
  - [ ] Use custom errors instead of strings
  - [ ] Optimize loops
  - [ ] Use events instead of storage where possible
  - [ ] Cache storage reads
- [ ] Gas reporting:
  - [ ] Baseline gas usage for key functions
  - [ ] Comparison after optimizations
  - [ ] Document gas costs
- [ ] Optimization without sacrificing:
  - [ ] Readability
  - [ ] Security
  - [ ] Functionality
- [ ] Gas benchmarks for:
  - [ ] User registration
  - [ ] Vault creation
  - [ ] Deposit/Withdraw operations
  - [ ] Protocol deployments

**Implementation Notes:**

- Use Hardhat's gas reporter plugin
- Compare before/after optimizations
- Document trade-offs
- Consider using libraries for common functions

---

### Issue #17: Security Audit Preparation

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `security`, `audit`  

**Priority:** HIGH

**Description:**

Prepare contracts for security audit. Add documentation, review code, and fix known vulnerabilities.

**Acceptance Criteria:**

- [ ] Code review checklist:
  - [ ] Reentrancy guards on external calls
  - [ ] Access control properly implemented
  - [ ] Input validation on all user inputs
  - [ ] Overflow/underflow protection
  - [ ] Front-running protections (if needed)
- [ ] Documentation:
  - [ ] NatSpec comments on all functions
  - [ ] Architecture documentation
  - [ ] Security assumptions documented
  - [ ] Known limitations documented
- [ ] Test coverage:
  - [ ] > 95% code coverage
  - [ ] Edge cases tested
  - [ ] Attack vectors tested
- [ ] Security considerations document
- [ ] Known issues/limitations document

**Implementation Notes:**

- Review OpenZeppelin security best practices
- Use Slither or similar tools for static analysis
- Consider formal verification for critical functions
- Prepare audit scope document

---

### Issue #18: Contract Documentation & NatSpec

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `documentation`  

**Priority:** MEDIUM

**Description:**

Add comprehensive NatSpec documentation to all contracts, functions, and events. Generate documentation from NatSpec.

**Acceptance Criteria:**

- [ ] NatSpec documentation for:
  - [ ] All contracts (title, author, notice)
  - [ ] All functions (description, params, returns, dev notes)
  - [ ] All events (description, params)
  - [ ] All state variables (description)
- [ ] Documentation format:
  - [ ] Use `@notice`, `@dev`, `@param`, `@return` tags
  - [ ] Include examples where helpful
  - [ ] Document error conditions
- [ ] Generate documentation:
  - [ ] Use solidity-docgen or similar
  - [ ] HTML output
  - [ ] Include in docs folder
- [ ] Architecture documentation:
  - [ ] Contract relationships
  - [ ] Data flow diagrams
  - [ ] Function call diagrams

**Implementation Notes:**

- Follow Solidity NatSpec standard
- Include examples for complex functions
- Document edge cases and error conditions
- Keep documentation up to date with code

---

## 📝 Issue Template

When creating new issues, use this template:

```markdown
### Issue #<number>: <Title>

**Status:** ❌ PENDING  

**Labels:** `<label1>`, `<label2>`  

**Priority:** HIGH | MEDIUM | LOW

**Description:**

<Detailed description of the issue>

**Acceptance Criteria:**

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

**Implementation Notes:**

- Technical details
- Code locations
- Dependencies
```

---

**Note:** When an issue is completed, move it to the "✅ Completed Issues" section and mark status as `✅ COMPLETED`.
