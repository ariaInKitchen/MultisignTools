// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface MultiSign {
    function submitTransaction(address destination, uint256 value, bytes memory data) external returns(uint256 transactionId);
    function confirmTransaction(uint256 transactionId) external;
}
