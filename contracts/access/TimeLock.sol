// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {TimeLockCommon} from "./TimeLockCommon.sol";

abstract contract TimeLock is TimeLockCommon {
    uint256 private _timeLockDuration;

    mapping(address user => uint256 timestamp) private _timeLocks;

    error LockedUser(address user);

    event DurationChanged(
        uint256 previousDuration,
        uint256 newDuration
    );
    event UserLockTimeChanged(
        address indexed user,
        uint256 timestamp
    );

    constructor(uint256 timeLockDuration) {
        _setDuration(timeLockDuration);
    }

    modifier timeLocked() {
        address caller = msg.sender;
        if (isLocked(caller)) {
            revert LockedUser(caller);
        }
        _lock(caller);
        _;
    }

    function duration() public view returns (uint256) {
        return _timeLockDuration;
    }

    function releaseTime(address user) public view returns (uint256) {
        return _timeLocks[user];
    }

    function lockTimeRemaining(address user) public view returns (uint256) {
        uint256 userLockTime = releaseTime(user);
        uint256 timeNow = _now();
        if (timeNow >= userLockTime) {
            return 0;
        }

        return userLockTime - timeNow;
    }

    function isLocked(address user) public view returns (bool) {
        return _now() < releaseTime(user);
    }

    function _lock(address user) internal {
        _setUserLockTime(user, _now() + _timeLockDuration);
    }

    function _setDuration(uint256 newDuration) internal {
        uint256 previousDuration = _timeLockDuration;
        _timeLockDuration = newDuration;

        emit DurationChanged(previousDuration, newDuration);
    }

    function _clear(address user) internal {
        _setUserLockTime(user, 0);
    }

    function _setUserLockTime(address user, uint256 timestamp) internal {
        _timeLocks[user] = timestamp;
        emit UserLockTimeChanged(user, timestamp);
    }
}
