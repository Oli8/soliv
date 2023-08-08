// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {TimeLockCommon} from "./TimeLockCommon.sol";

abstract contract TimeLock is TimeLockCommon {
    uint256 private _timeLockDuration;

    mapping(address user => uint256 timestamp) private _timeLocks;

    event DurationChanged(
        uint256 previousDuration,
        uint256 newDuration
    );

    constructor(uint256 timeLockDuration) {
        _setDuration(timeLockDuration);
    }

    modifier timeLocked() {
        address caller = msg.sender;
        require(
            !isLocked(caller),
            "TimeLock: Account under timelock"
        );
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
        _timeLocks[user] = _now() + _timeLockDuration;
    }

    function _setDuration(uint256 newDuration) internal {
        uint256 previousDuration = _timeLockDuration;
        _timeLockDuration = newDuration;

        emit DurationChanged(previousDuration, newDuration);
    }

    function _clear(address user) internal {
        _timeLocks[user] = 0;
    }
}
