// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {TimeLockCommon} from "./TimeLockCommon.sol";

abstract contract TimeLockGroups is TimeLockCommon {
    struct TimeLockData {
        mapping(address user => uint256 timestamp) timestamps;
        uint256 duration;
    }

    mapping(bytes32 name => TimeLockData data) private _timeLocks;

    error LockedUser(bytes32 lockName, address user);

    event DurationChanged(
        bytes32 name,
        uint256 previousDuration,
        uint256 newDuration
    );

    modifier timeLocked(bytes32 name) {
        address caller = msg.sender;
        if (isLocked(name, caller)) {
            revert LockedUser({
                lockName: name,
                user: caller
            });
        }
        _lock(name, caller);
        _;
    }

    function duration(bytes32 name) public view returns (uint256) {
        return _timeLocks[name].duration;
    }

    function releaseTime(bytes32 name, address user)
        public
        view
        returns (uint256)
    {
        return _timeLocks[name].timestamps[user];
    }

    function lockTimeRemaining(bytes32 name, address user)
        public
        view
        returns (uint256)
    {
        uint256 userLockTime = releaseTime(name, user);
        uint256 timeNow = _now();
        if (timeNow >= userLockTime) {
            return 0;
        }

        return userLockTime - timeNow;
    }

    function isLocked(bytes32 name, address user) public view returns (bool) {
        return _now() < releaseTime(name, user);
    }

    function _lock(bytes32 name, address user) internal {
        _timeLocks[name].timestamps[user] = _now() + duration(name);
    }

    function _setDuration(bytes32 name, uint256 newDuration) internal {
        uint256 previousDuration = duration(name);
        _timeLocks[name].duration = newDuration;

        emit DurationChanged(name, previousDuration, newDuration);
    }

    function _clear(bytes32 name, address user) internal {
        _timeLocks[name].timestamps[user] = 0;
    }
}
