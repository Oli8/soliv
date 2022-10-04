# Access

## Contracts

- [TimeLock](TimeLock.sol)

Provides a way to limit access to time locked function.\
E.g. a user can only call a function once in a 3 days span.

/!\ Be wary that this contract uses `block.timestamp` and its value can be manipulated by miners.\
Therefore a duration under 15 minutes should be avoided for non trivial actions.


```solidity
pragma solidity ^0.8.0;

import "soliv/contracts/access/TimeLock.sol";

contract SharedVault is TimeLock {
    constructor() TimeLock(3 days) {}

    partialWithdraw() public timeLocked {
        uint amountWithdrawn = 0.01 ether;
        require(address(this).balance >= amountWithdrawn, "Insufficient funds");
        (bool sent,) = msg.sender.call{value: amountWithdrawn}("");
        require(sent, "Failed to withdraw");
    }
}
```
