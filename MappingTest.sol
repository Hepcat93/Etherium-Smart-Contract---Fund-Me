// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

mapping(address => uint256) addressToAmountFunded;

// Add a contribution
if (msg.value > 0) {
    addressToAmountFunded[msg.sender] += msg.value;
}

// Retrieve a contribution
uint256 amount = addressToAmountFunded[msg.sender];
