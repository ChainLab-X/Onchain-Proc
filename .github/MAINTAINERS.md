# Maintainer Guide

This guide is for project maintainers who are managing projects within the **Onchain-Proc** repository. It outlines how to structure your project issues and task lists to make it easy for contributors to pick up work.

## Structuring Project Issues

We recommend creating an `ISSUES.md` or `TODO.md` file in your project root to list available tasks. This keeps everything self-contained and easy to track.

### Recommended Issue Format

Use the following structure for defining tasks. This ensures contributors have all the context they need.

```markdown
### Issue #<Number>: <Title>
**Status:** ❌ PENDING / ✅ COMPLETED  
**Labels:** `smart-contracts`, `frontend`, `feature`, `bug`, `good-first-issue`  
**Priority:** HIGH / MEDIUM / LOW

**Description:**
Briefly describe the task, the problem it solves, or the feature to be implemented.

**Acceptance Criteria:**
- [ ] Requirement 1
- [ ] Requirement 2
- [ ] Requirement 3 (e.g., "Tests pass", "Events emitted")
- [ ] Documentation updated

**Technical/Implementation Notes:**
- Mention specific files to touch (e.g., `contracts/MyContract.sol`)
- Mention libraries to use (e.g., "Use OpenZeppelin ReentrancyGuard")
- Any specific patterns or constraints
```

## Example `ISSUES.md`

```markdown
# Project Name Issues

## Pending Tasks

### Issue #1: Implement ERC20 Token
**Status:** ❌ PENDING
**Labels:** `smart-contracts`, `token`
**Priority:** HIGH

**Description:**
Create a standard ERC20 token for the platform governance.

**Acceptance Criteria:**
- [ ] Inherit from OpenZeppelin ERC20
- [ ] Implement permit functionality
- [ ] Mint initial supply to deployer

**Technical Notes:**
- File: `contracts/GovToken.sol`
- Use Solidity ^0.8.20
```

## helping New Contributors

1. **Tag issues** with `good-first-issue` for beginners.
2. **Be responsive** to Pull Requests.
3. **Link** to this `ISSUES.md` file from your project's `README.md`.
