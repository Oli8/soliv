// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {TimeLockGroups} from "../access/TimeLockGroups.sol";

contract TimeLockGroupsMock is TimeLockGroups {
    string public constant GOUVERNANCE_LOCK = "GOUVERNANCE";
    string public constant APPLICATION_LOCK = "APPLICATION";

    constructor() {
        _setDuration(GOUVERNANCE_LOCK, 3 days);
        _setDuration(APPLICATION_LOCK, 1 days);
    }

    function setTimeLockDuration(string memory lockName, uint256 newDuration) public {
        _setDuration(lockName, newDuration);
    }

    function clearUserTimeLock(string memory lockName, address user) public {
        _clear(lockName, user);
    }

    function lockUser(string memory lockName, address user) public {
        _lock(lockName, user);
    }

    function voteBan() external timeLocked(GOUVERNANCE_LOCK) {}

    function createProposal() external timeLocked(GOUVERNANCE_LOCK) {}

    function approve() external timeLocked(APPLICATION_LOCK) {}

    function action() external timeLocked("pla") {}
}
