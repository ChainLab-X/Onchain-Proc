##  My Takeaways from Yesterday’s Solidity Class

Yesterday's class was alright and I learnt quite a lot.

###  Solidity & Smart Contracts
Solidity is basically the language we use to write programs (called smart contracts) that live on the blockchain. These contracts handle stuff like sending tokens or storing data, and once deployed, they can’t be changed.

###  Variables and Functions
We went over how to declare variables like numbers, addresses, or strings, and how to write functions that do stuff with them like set or return values.

###  Variable Scope
This part helped me realize which variables are visible where. Some are global (like `msg.sender`), some live only inside functions, and others are saved on the blockchain as part of the contract’s state.

###  Visibility
We also covered visibility keywords: `public`, `private`, `internal`, and `external`. These control who can access what. For example, `private` functions can’t be called from outside the contract.

###  Constructors
Constructors are like the welcome message of a contract they run only once when you deploy it. Useful for setting things like the contract owner.

###  Interfaces
Interfaces were a bit tricky but make sense now they’re like blueprints for how one contract can talk to another without needing to know the full code.

### State Mutability
Functions can be marked as `view`, `pure`, or `payable`. `view` can read blockchain data, `pure` doesn’t interact with blockchain at all, and `payable` means the function can receive Ether.

###  Error Handling
We also got to talk about error handling. `require` is great for input checks, `assert` is for catching internal bugs, and `revert` lets you stop execution and give a reason.

---

So yeah, overall the class helped me get more confident with Solidity basics.
