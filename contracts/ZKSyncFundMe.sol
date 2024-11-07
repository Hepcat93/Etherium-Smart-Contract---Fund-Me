// SPDX-License-Identifier: MIT

//Get funds from users
//Withdraw funds
//Set a minimum funding value in USD

pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

//libraries can't have any state variables and all functions must be marked internal

library PriceConverter {

    function getPrice() internal view returns(uint256) {
        // Address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // ABI
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF);
        (,int256 price,,,) = priceFeed.latestRoundData();
        // Price of ETH in terms of USD
        // 2000.00000000
        return uint256(price * 1e10);
    }

    function getConversionRate(uint256 ethAmount) internal view returns(uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }
    
    function getVersion() internal view returns (uint256) {
        return AggregatorV3Interface(0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF).version();
    }
}

error NotOwner();

contract FundMe {

    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18;

    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    address public immutable i_owner;

    //a function which is called right on the contract deployment
    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        // Allow users to send $
        // Have a minimum $ sent $5
        // 1. How do we send ETH to this contract?

        // Global functions and keywords can be found in Solidity documentation!
        // If transaction reverts, then the yet non-spended gas (allocated for the non-executed piece of code
        // below the requite function) is refunded

        //MINIMUM_USD = MINIMUM_USD + 2;

        //require(getConversionRate(msg.value) >= MINIMUM_USD, "didn't send enough ETH"); // 1e18 = 1 ETH = 1 000 000 000 000 000 000 WEI
        //Cnhages due to using our newly created library from PriceConverter.sol
        //if second variable is needed - it goes to parentheses
        require(msg.value.getConversionRate() >= MINIMUM_USD, "didn't send enough ETH");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender] + msg.value;
    }

    function withdraw() public onlyOwner {
        //resetting mapping
        // for(/* starting index, ending index, step amount */ )
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) { //++ means +1
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        //this way we reset the array by creating the new instance under the old name with length 0
        funders = new address[] (0);
        
        /*// transfer 2300 gas cap, returns error
        payable(msg.sender).transfer(address(this).balance);
        // send 2300 gas cap, returns bool
        bool sendSuccess = payable(msg.sender).send(address(this).balance);
        require(sendSuccess, "Send failed");*/
        // call forward all gas or set gas, returns bool
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    // the order of the underscore matters! underscore = the rest of the function body
    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Must be owner!");
        // that's analog for require but without the conditional beforehand
        // so we can revert any transaction or function in the middle of a function call
        if(msg.sender != i_owner) { revert NotOwner(); }
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

}

// Chainlink ZKSync Testnet ETH/USD address: 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF