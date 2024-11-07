// SPDX-License-Identifier: MIT

//Get funds from users
//Withdraw funds
//Set a minimum funding value in USD

pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {

    using PriceConverter for uint256;

    uint256 public minimumUsd = 5e18;

    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    function fund() public payable {
        // Allow users to send $
        // Have a minimum $ sent $5
        // 1. How do we send ETH to this contract?

        // Global functions and keywords can be found in Solidity documentation!
        // If transaction reverts, then the yet non-spended gas (allocated for the non-executed piece of code
        // below the requite function) is refunded

        //minimumUsd = minimumUsd + 2;

        //require(getConversionRate(msg.value) >= minimumUsd, "didn't send enough ETH"); // 1e18 = 1 ETH = 1 000 000 000 000 000 000 WEI
        //Cnhages due to using our newly created library from PriceConverter.sol
        //if second variable is needed - it goes to parentheses
        require(msg.value.getConversionRate() >= minimumUsd, "didn't send enough ETH");
        addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender] + msg.value;
    }

    // function withdraw() public {}

}