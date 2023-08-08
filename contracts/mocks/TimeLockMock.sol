// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {TimeLock} from "../access/TimeLock.sol";

contract TimeLockMock is TimeLock {
    constructor() TimeLock(3 days) {}

    function timeLockedAction() public timeLocked {}

    function setTimeLockDuration(uint256 newDuration) public {
        _setDuration(newDuration);
    }

    function clearUserTimeLock(address user) public {
        _clear(user);
    }

    function lockUser(address user) public {
        _lock(user);
    }
}
