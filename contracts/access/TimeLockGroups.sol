// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {TimeLockCommon} from "./TimeLockCommon.sol";

abstract contract TimeLockGroups is TimeLockCommon {
    struct TimeLockData {
        // FIXME: lower uint?
        mapping(address => uint256) timeLocks;
        uint256 duration;
    }
    // FIXME: use bytes(32?) (+hash?)?
    mapping(string name => TimeLockData data) private _timeLocks;

    event DurationChanged(
        string name,
        uint256 previousDuration,
        uint256 newDuration
    );

    modifier timeLocked(string memory name) {
        // TODO: lock name in error msg ?
        address caller = msg.sender;
        require(
            !isLocked(name, caller),
            "TimeLock: Account under timelock"
        );
        _lock(name, caller);
        _;
    }

    function duration(string memory name) public view returns (uint256) {
        return _timeLocks[name].duration;
    }

    function releaseTime(string memory name, address user)
        public
        view
        returns (uint256)
    {
        return _timeLocks[name].timeLocks[user];
    }

    function lockTimeRemaining(string memory name, address user)
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

    function isLocked(string memory name, address user) public view returns (bool) {
        // FIXME: <= ??
        return _now() < releaseTime(name, user);
    }

    function _lock(string memory name, address user) internal {
        _timeLocks[name].timeLocks[user] = _now() + duration(name);
    }

    function _setDuration(string memory name, uint256 newDuration) internal {
        uint256 previousDuration = duration(name);
        _timeLocks[name].duration = newDuration;

        emit DurationChanged(name, previousDuration, newDuration);
    }

    function _clear(string memory name, address user) internal {
        _timeLocks[name].timeLocks[user] = 0;
    }
}
