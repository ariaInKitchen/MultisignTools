// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface CToken {
    function _reduceReserves(uint reduceAmount) external returns (uint);
}
