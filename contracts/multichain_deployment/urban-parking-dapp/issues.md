# Smart Contract Issues

This file contains all development tasks for the Urban Parking dApp smart contracts. Each issue represents a feature or improvement needed to complete the project.

## ✅ Completed Issues

- [x] **Issue #1:** Core Smart Contract Architecture
- [x] **Issue #2:** Project Scaffold Setup

---

## ❌ Pending Issues

### Issue #3: Deployment Scripts

**Status:** ✅ COMPLETED  

**Labels:** `smart-contracts`, `deployment`, `infrastructure`, `completed`  

**Priority:** HIGH

**Description:**

Create deployment scripts for all three contracts (ParkingMarket, ParkingToken, ParkingDAO) with proper configuration and verification support.

**Acceptance Criteria:**

- [x] `scripts/deploy.ts` deploys all contracts in correct order
- [x] Deployment script accepts network-specific parameters
- [x] Contract addresses are logged and saved to deployment file
- [x] Deployment works on multiple networks (Base, Polygon, etc.)
- [x] Script handles deployment failures gracefully
- [x] Constructor parameters are configurable via environment variables

**Implementation Notes:**

- ✅ Deploy ParkingToken first (standalone) with configurable name, symbol, initialPrice
- ✅ Deploy ParkingDAO second (standalone)
- ✅ Deploy ParkingMarket last (requires fee collector address - uses DAO address)
- ✅ Save deployment addresses to `deployments/<network>.json`
- ✅ Comprehensive error handling with partial deployment data saving on failures
- ✅ Environment variables: `PARKING_TOKEN_NAME`, `PARKING_TOKEN_SYMBOL`, `PARKING_TOKEN_INITIAL_PRICE`
- ✅ Commit: `da91fa0` - "feat(deployment): implement complete deployment script for all contracts"

---

### Issue #4: Contract Verification Scripts

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `verification`, `infrastructure`  

**Priority:** HIGH

**Description:**

Create verification scripts to verify deployed contracts on block explorers (Etherscan, BaseScan, PolygonScan).

**Acceptance Criteria:**

- [ ] `scripts/verify.ts` verifies all deployed contracts
- [ ] Verification includes constructor arguments
- [ ] Script reads deployment addresses from deployment file
- [ ] Works across multiple networks
- [ ] Handles already-verified contracts gracefully
- [ ] Provides clear success/error messages

**Implementation Notes:**

- Use Hardhat's verify plugin
- Read deployment data from `deployments/<network>.json`
- Include all constructor arguments for verification
- Add network-specific API keys to `.env`

---

### Issue #5: Comprehensive Unit Tests - ParkingMarket

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `testing`, `parking-market`  

**Priority:** HIGH

**Description:**

Write comprehensive unit tests for the ParkingMarket contract covering all functions, edge cases, and security scenarios.

**Acceptance Criteria:**

- [ ] Test space listing functionality
- [ ] Test space updates (price, availability)
- [ ] Test reservation creation with payment
- [ ] Test reservation completion
- [ ] Test platform fee calculations
- [ ] Test access control (only space owner can update)
- [ ] Test edge cases (zero values, invalid inputs)
- [ ] Test reentrancy protection
- [ ] Test event emissions
- [ ] Test getter functions (getAllSpaces, getAvailableSpaces)
- [ ] Code coverage > 90%

**Implementation Notes:**

- Use Hardhat + Chai for testing
- Create test fixtures for common scenarios
- Test with multiple users and spaces
- Verify ETH transfers are correct

---

### Issue #6: Comprehensive Unit Tests - ParkingToken

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `testing`, `erc20`  

**Priority:** HIGH

**Description:**

Write comprehensive unit tests for the ParkingToken ERC20 contract covering token operations, pricing, and redemption.

**Acceptance Criteria:**

- [ ] Test token purchase with ETH
- [ ] Test token redemption for ETH
- [ ] Test token price updates
- [ ] Test token transfers (ERC20 standard)
- [ ] Test token marking as used for reservations
- [ ] Test access control (only owner functions)
- [ ] Test edge cases (insufficient balance, zero amounts)
- [ ] Test contract balance management
- [ ] Test withdrawal functionality
- [ ] Code coverage > 90%

**Implementation Notes:**

- Test ERC20 compliance
- Verify price calculations are correct
- Test with multiple users
- Check contract ETH balance after operations

---

### Issue #7: Comprehensive Unit Tests - ParkingDAO

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `testing`, `dao`, `governance`  

**Priority:** HIGH

**Description:**

Write comprehensive unit tests for the ParkingDAO contract covering proposal creation, voting, execution, and governance.

**Acceptance Criteria:**

- [ ] Test voter addition/removal
- [ ] Test proposal creation (all types)
- [ ] Test voting mechanism (for/against)
- [ ] Test proposal execution after voting period
- [ ] Test quorum requirements
- [ ] Test passing threshold requirements
- [ ] Test access control (roles)
- [ ] Test voting power calculations
- [ ] Test proposal status transitions
- [ ] Test edge cases (double voting, expired proposals)
- [ ] Code coverage > 90%

**Implementation Notes:**

- Use time manipulation for voting periods
- Test with multiple voters
- Verify proposal state changes correctly
- Test all proposal types (FeeChange, RuleChange, etc.)

---

### Issue #8: Integration Tests - Full Workflow

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `testing`, `integration`  

**Priority:** MEDIUM

**Description:**

Create integration tests that test the complete user workflow across all three contracts working together.

**Acceptance Criteria:**

- [ ] Test complete parking flow:
  - [ ] User purchases parking tokens
  - [ ] Owner lists parking space
  - [ ] User reserves space using tokens
  - [ ] User completes reservation
- [ ] Test DAO governance flow:
  - [ ] Create proposal to change parking fees
  - [ ] Multiple users vote
  - [ ] Proposal executes successfully
- [ ] Test multi-user scenarios
- [ ] Test cross-contract interactions
- [ ] Verify state consistency across contracts

**Implementation Notes:**

- Create realistic user scenarios
- Test with multiple users simultaneously
- Verify all contracts work together correctly
- Test failure scenarios and rollbacks

---

### Issue #9: Gas Optimization

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `optimization`, `gas`  

**Priority:** MEDIUM

**Description:**

Optimize contract code to reduce gas costs for common operations. Focus on storage optimization, loop efficiency, and function call costs.

**Acceptance Criteria:**

- [ ] Reduce gas cost for `listSpace()` by 10%
- [ ] Reduce gas cost for `reserveSpace()` by 10%
- [ ] Optimize storage layout in all contracts
- [ ] Use events instead of storage where appropriate
- [ ] Minimize SLOAD/SSTORE operations
- [ ] Benchmark gas costs before and after
- [ ] Document optimization techniques used

**Implementation Notes:**

- Use `forge test --gas-report` or Hardhat gas reporter
- Consider packing storage variables
- Use `calldata` instead of `memory` where possible
- Optimize loops and array operations

---

### Issue #10: Security Audit Preparation

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `security`, `audit`  

**Priority:** HIGH

**Description:**

Prepare contracts for security audit by adding comprehensive NatSpec documentation, security checks, and running static analysis tools.

**Acceptance Criteria:**

- [ ] All functions have complete NatSpec comments
- [ ] All contracts have detailed documentation
- [ ] Run Slither static analysis (no critical issues)
- [ ] Run Mythril security scanner
- [ ] Add reentrancy guards where needed
- [ ] Implement checks-effects-interactions pattern
- [ ] Add input validation to all public functions
- [ ] Document known limitations and assumptions
- [ ] Create security considerations document

**Implementation Notes:**

- Install and run Slither: `slither .`
- Fix all high and medium severity issues
- Add `@notice`, `@dev`, `@param`, `@return` to all functions
- Document security assumptions

---

### Issue #11: Multi-Network Deployment Configuration

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `deployment`, `infrastructure`  

**Priority:** MEDIUM

**Description:**

Configure deployment for multiple networks (Ethereum, Polygon, Base, Arbitrum, Optimism, Lisk Sepolia) with network-specific parameters.

**Acceptance Criteria:**

- [ ] Hardhat config includes all target networks
- [ ] Network-specific RPC URLs configured
- [ ] Network-specific block explorer API keys
- [ ] Deployment script adapts to network (gas price, confirmations)
- [ ] Create deployment documentation for each network
- [ ] Test deployment on testnets first
- [ ] Verify contracts on all networks

**Implementation Notes:**

- Update `hardhat.config.ts` with all networks
- Use environment variables for sensitive data
- Document network-specific requirements
- Consider gas price strategies per network

---

### Issue #12: Interaction Scripts

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `scripts`, `utilities`  

**Priority:** LOW

**Description:**

Create utility scripts (`scripts/interact.ts`) for common contract interactions like listing spaces, making reservations, and creating proposals.

**Acceptance Criteria:**

- [ ] Script to list a parking space
- [ ] Script to reserve a parking space
- [ ] Script to purchase parking tokens
- [ ] Script to create a DAO proposal
- [ ] Script to vote on proposals
- [ ] Script to query contract state (spaces, reservations)
- [ ] All scripts accept command-line arguments
- [ ] Clear usage documentation

**Implementation Notes:**

- Use commander.js or yargs for CLI
- Read contract addresses from deployment files
- Provide helpful error messages
- Add examples to README

---

### Issue #13: Event Indexing & Subgraph

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `indexing`, `subgraph`  

**Priority:** LOW

**Description:**

Create a subgraph for indexing contract events to enable efficient querying of parking spaces, reservations, and DAO proposals.

**Acceptance Criteria:**

- [ ] Subgraph schema defined for all entities
- [ ] Event handlers for all contract events
- [ ] Entities: ParkingSpace, Reservation, Proposal, Vote
- [ ] Subgraph deployed to The Graph network
- [ ] GraphQL queries documented
- [ ] Frontend can query subgraph data

**Implementation Notes:**

- Use Graph Protocol
- Create `subgraph.yaml` manifest
- Write event handlers in AssemblyScript
- Test locally with graph-node
- Deploy to hosted service or decentralized network

---

### Issue #14: Upgradeable Contract Pattern (Optional)

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `upgradeable`, `proxy`  

**Priority:** LOW

**Description:**

Implement upgradeable contract pattern using OpenZeppelin's UUPS or Transparent Proxy pattern for future contract improvements.

**Acceptance Criteria:**

- [ ] Convert contracts to upgradeable versions
- [ ] Implement initialization functions
- [ ] Add upgrade authorization
- [ ] Test upgrade process
- [ ] Document upgrade procedure
- [ ] Ensure storage layout compatibility

**Implementation Notes:**

- Use OpenZeppelin Upgrades plugin
- Choose between UUPS and Transparent Proxy
- Be careful with storage layout
- Test upgrades thoroughly
- Consider if upgradability is needed

---

### Issue #15: Emergency Pause Functionality

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `security`, `emergency`  

**Priority:** MEDIUM

**Description:**

Add emergency pause functionality to ParkingMarket contract to halt operations in case of security issues or bugs.

**Acceptance Criteria:**

- [ ] Implement Pausable pattern from OpenZeppelin
- [ ] Add `pause()` and `unpause()` functions (owner only)
- [ ] Pause blocks critical operations (reserveSpace, listSpace)
- [ ] Pause does not block withdrawals or completions
- [ ] Emit events on pause/unpause
- [ ] Add tests for pause functionality
- [ ] Document pause scenarios

**Implementation Notes:**

- Inherit from OpenZeppelin's `Pausable`
- Add `whenNotPaused` modifier to critical functions
- Allow users to complete existing reservations when paused
- Consider multi-sig for pause authority

---

### Issue #16: Stablecoin Payment Support

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `feature`, `payments`  

**Priority:** MEDIUM

**Description:**

Add support for stablecoin payments (USDC, USDT, DAI) in addition to native ETH for parking reservations.

**Acceptance Criteria:**

- [ ] Accept ERC20 tokens for reservations
- [ ] Support multiple stablecoins (USDC, USDT, DAI)
- [ ] Update payment logic to handle token transfers
- [ ] Add token approval requirements
- [ ] Update fee distribution for tokens
- [ ] Add token balance checks
- [ ] Update tests for token payments
- [ ] Document supported tokens

**Implementation Notes:**

- Add token address parameter to reservation
- Use `transferFrom()` for token payments
- Handle different token decimals
- Consider using a price oracle for conversion
- Update ParkingMarket contract

---

### Issue #17: Automated Reservation Expiry

**Status:** ❌ PENDING  

**Labels:** `smart-contracts`, `feature`, `automation`  

**Priority:** LOW

**Description:**

Implement automated reservation expiry mechanism using Chainlink Keepers or similar automation service.

**Acceptance Criteria:**

- [ ] Reservations automatically expire after end time
- [ ] Expired reservations free up parking slots
- [ ] Integration with Chainlink Automation
- [ ] Keeper-compatible interface implemented
- [ ] Gas-efficient expiry checks
- [ ] Events emitted on expiry
- [ ] Tests for expiry mechanism

**Implementation Notes:**

- Implement `checkUpkeep()` and `performUpkeep()`
- Use Chainlink Automation for decentralized execution
- Batch process multiple expirations
- Consider gas costs for automation

---

### Issue #18: Documentation & Developer Guide

**Status:** ❌ PENDING  

**Labels:** `documentation`, `developer-experience`  

**Priority:** MEDIUM

**Description:**

Create comprehensive documentation including architecture overview, API reference, deployment guide, and developer tutorials.

**Acceptance Criteria:**

- [ ] Architecture documentation (ARCHITECTURE.md)
- [ ] API reference for all contracts
- [ ] Deployment guide (DEPLOYMENT.md)
- [ ] Developer setup guide
- [ ] Integration examples
- [ ] Troubleshooting guide
- [ ] Contributing guidelines
- [ ] Code comments and NatSpec complete

**Implementation Notes:**

- Use clear diagrams for architecture
- Include code examples
- Document common pitfalls
- Add FAQ section
- Keep documentation up to date

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

## 🏷️ Label Definitions

- `smart-contracts` - Core contract development
- `testing` - Unit, integration, or E2E tests
- `deployment` - Deployment scripts and configuration
- `security` - Security audits and improvements
- `optimization` - Gas optimization and performance
- `documentation` - Documentation and guides
- `infrastructure` - Build tools and CI/CD
- `feature` - New features
- `bug` - Bug fixes

---

**Note:** When an issue is completed, move it to the "✅ Completed Issues" section and mark status as `✅ COMPLETED`.
