// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

abstract contract TimeLockCommon {
    function _now() internal view returns (uint256) {
        return block.timestamp;
    }
}
