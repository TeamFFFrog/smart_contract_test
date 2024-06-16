// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/RegToken.sol";

contract DeployRegToken is Script {
    function run() external {
        address priceFeed = 0x694AA1769357215DE4FAC081bf1f309aDC325306; // Replace with actual Chainlink ETH/USD price feed address
        address owner = msg.sender;
        uint256 _feeRate = 1;

        vm.startBroadcast();

        // Deploy the RegToken contract
        RegToken regToken = new RegToken(priceFeed, owner, _feeRate);

        console.log("RegToken deployed at:", address(regToken));

        vm.stopBroadcast();
    }
}
