// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {TimeLockGroups} from "../access/TimeLockGroups.sol";

contract TimeLockGroupsMock is TimeLockGroups {
    bytes32 public constant GOUVERNANCE_LOCK = keccak256("GOUVERNANCE");
    bytes32 public constant APPLICATION_LOCK = keccak256("APPLICATION");

    constructor() {
        _setDuration(GOUVERNANCE_LOCK, 3 days);
        _setDuration(APPLICATION_LOCK, 1 days);
    }

    function setTimeLockDuration(bytes32 lockName, uint256 newDuration) public {
        _setDuration(lockName, newDuration);
    }

    function clearUserTimeLock(bytes32 lockName, address user) public {
        _clear(lockName, user);
    }

    function lockUser(bytes32 lockName, address user) public {
        _lock(lockName, user);
    }

    function voteBan() external timeLocked(GOUVERNANCE_LOCK) {}

    function createProposal() external timeLocked(GOUVERNANCE_LOCK) {}

    function approve() external timeLocked(APPLICATION_LOCK) {}

    function action() external timeLocked("pla") {}
}
