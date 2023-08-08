# Access

## Contracts

- [TimeLock](TimeLock.sol)

Provides a way to limit access to time locked function.\
E.g. a user can only call a function once in a 3 days span.

**/!\\ Warning:** Be wary that this contract uses `block.timestamp` and its value can be manipulated by miners.\
Therefore a duration under 15 minutes should be avoided for non trivial actions.

**Limitations**: Each `timeLocked` function will share the same locking mechanism.\
You may use [TimeLockGroups](TimeLockGroups.sol) for that purpose.

```solidity
pragma solidity ^0.8.18;

import {TimeLock} "soliv/contracts/access/TimeLock.sol";

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

<hr>

- [TimeLockGroups](TimeLockGroups.sol)

Expands on the TimeLock contract to provide multiple time-locked access to functions.
With this you can apply different lock durations to different functions or function groups.

E.g., a user may only call functions in GOUVERNANCE once every 3 days, but functions in APPLICATION can be called once a day.

"Locks" are referred to by their `bytes32` identifier and should be unique.
Refer to the example below to see how to create and use one.

**/!\\ Warning:** Be wary that this contract uses `block.timestamp` and its value can be manipulated by miners.\
Therefore a duration under 15 minutes should be avoided for non trivial actions.

```solidity
pragma solidity ^0.8.18;

import {TimeLockGroups} from "soliv/contracts/access/TimeLockGroups.sol";

contract MyDAO is TimeLockGroups {
    bytes32 public constant GOUVERNANCE_LOCK = keccak256("GOUVERNANCE");
    bytes32 public constant APPLICATION_LOCK = keccak256("APPLICATION");

    constructor() {
        _setDuration(GOUVERNANCE_LOCK, 3 days);
        _setDuration(APPLICATION_LOCK, 1 days);
    }

    function voteBan() external timeLocked(GOUVERNANCE_LOCK) {
      // ...
    }

    function createProposal() external timeLocked(GOUVERNANCE_LOCK) {
      // ...
    }

    function approve() external timeLocked(APPLICATION_LOCK) {
      // ...
    }
}
```
