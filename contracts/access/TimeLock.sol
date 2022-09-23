// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract TimeLock {
    uint256 private _timeLockDuration;

    mapping(address => uint256) private _timeLocks;

    event DurationChanged(
        address indexed from,
        uint256 previousDuration,
        uint256 newDuration
    );

    constructor(uint256 timeLockDuration) {
        _timeLockDuration = timeLockDuration;
    }

    function duration() public view returns (uint256) {
        return _timeLockDuration;
    }

    function releaseTime(address user) public view returns (uint256) {
        uint256 userLockTime = _timeLocks[user];
        uint256 timeNow = _now();
        if (timeNow >= userLockTime) {
            return 0;
        }

        return userLockTime - timeNow;
    }

    function isLocked(address user) public view returns (bool) {
        return _now() <= _timeLocks[user];
    }

    function setTimeLockDuration(uint256 newDuration) public virtual {
        uint256 previousDuration = _timeLockDuration;
        _timeLockDuration = newDuration;
        emit DurationChanged(msg.sender, previousDuration, newDuration);
    }

    function clear(address user) public virtual {
        _timeLocks[user] = 0;
    }

    modifier onlyUnlocked() {
        address caller = msg.sender;
        require(
            !isLocked(caller),
            "TimeLock: Account under timelock"
        );
        _timeLocks[caller] = _now() + _timeLockDuration;
        _;
    }

    function _now() private view returns (uint256) {
        return block.timestamp;
    }
}
