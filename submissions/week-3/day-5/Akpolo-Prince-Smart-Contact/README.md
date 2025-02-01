# TaskPledge: Decentralized Task Commitment and Penalty System

## Overview
TaskPledge is a Solidity smart contract that allows users to commit to completing tasks by locking up a small amount of cryptocurrency as a pledge. If the user completes the task by the deadline, they get their pledge back. If they fail, the pledged amount is donated to a charity of their choice.

This project demonstrates the use of key Solidity concepts such as data types, constructors, modifiers, functions, mappings, structs, and error handling.

---

## Features
1. **Task Creation**:
   - Users can create tasks by providing a description and deadline.
   - A hardcoded pledge amount of `1000000 wei` (0.000001 ETH) is locked in the contract.

2. **Task Completion**:
   - Users can mark tasks as completed before the deadline.
   - If completed, the pledged amount is returned to the user.

3. **Pledge Donation**:
   - If the task is not completed by the deadline, the pledged amount is donated to an approved charity.

4. **Charity Management**:
   - The contract owner can add or remove approved charities.

5. **Access Control**:
   - Only the task creator can mark a task as completed.
   - Only the contract owner can manage approved charities.

---

## How to Use
1. **Deploy the Contract**:
   - Compile and deploy the contract on a testnet (e.g., Sepolia) using Remix or Hardhat.

2. **Create a Task**:
   - Call the `createTask` function with a description and deadline.
   - Example:
     ```solidity
     createTask("Write a blog post", 1698883200);
     ```

3. **Complete a Task**:
   - Call the `completeTask` function with the task ID before the deadline.
   - Example:
     ```solidity
     completeTask(1);
     ```

4. **Donate a Pledge**:
   - If the task is not completed by the deadline, call the `donatePledge` function with the task ID and charity address.
   - Example:
     ```solidity
     donatePledge(1, 0xCharityAddress);
     ```

5. **Manage Charities**:
   - The contract owner can add or remove charities using the `addCharity` and `removeCharity` functions.

---

## Deployment
- The contract is deployed on the Sepolia testnet.
- The contract is verified on Etherscan for transparency.

---

