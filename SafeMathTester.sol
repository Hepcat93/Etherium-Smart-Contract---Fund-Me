// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract SafeMathTester {
    uint8 public bigNumber = 255; // checked


    //versions of Solidity of 0.7.6 and below don't check variables for overflow, "uncheck" command reverts this for
    //the newer versions
    function add() public {
        unchecked {bigNumber = bigNumber + 1;}
    }
}