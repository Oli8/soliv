// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {TimeLockCommon} from "./TimeLockCommon.sol";

abstract contract TimeLockGroups is TimeLockCommon {
    struct TimeLockData {
        mapping(address user => uint256 timestamp) timestamps;
        uint256 duration;
    }

    mapping(bytes32 lockName => TimeLockData data) private _timeLocks;

    error LockedUser(bytes32 lockName, address user);

    event DurationChanged(
        bytes32 indexed lockName,
        uint256 previousDuration,
        uint256 newDuration
    );
    event UserLockTimeChanged(
        bytes32 indexed lockName,
        address indexed user,
        uint256 timestamp
    );

    modifier timeLocked(bytes32 lockName) {
        address caller = msg.sender;
        if (isLocked(lockName, caller)) {
            revert LockedUser({
                lockName: lockName,
                user: caller
            });
        }
        _lock(lockName, caller);
        _;
    }

    function duration(bytes32 lockName) public view returns (uint256) {
        return _timeLocks[lockName].duration;
    }

    function releaseTime(bytes32 lockName, address user)
        public
        view
        returns (uint256)
    {
        return _timeLocks[lockName].timestamps[user];
    }

    function lockTimeRemaining(bytes32 lockName, address user)
        public
        view
        returns (uint256)
    {
        uint256 userLockTime = releaseTime(lockName, user);
        uint256 timeNow = _now();
        if (timeNow >= userLockTime) {
            return 0;
        }

        return userLockTime - timeNow;
    }

    function isLocked(bytes32 lockName, address user) public view returns (bool) {
        return _now() < releaseTime(lockName, user);
    }

    function _lock(bytes32 lockName, address user) internal {
        _setUserLockTime(lockName, user, _now() + duration(lockName));
    }

    function _setDuration(bytes32 lockName, uint256 newDuration) internal {
        uint256 previousDuration = duration(lockName);
        _timeLocks[lockName].duration = newDuration;

        emit DurationChanged(lockName, previousDuration, newDuration);
    }

    function _clear(bytes32 lockName, address user) internal {
        _setUserLockTime(lockName, user, 0);
    }

    function _setUserLockTime(bytes32 lockName, address user, uint256 timestamp)
        internal
    {
        _timeLocks[lockName].timestamps[user] = timestamp;
        emit UserLockTimeChanged(lockName, user, timestamp);
    }
}
