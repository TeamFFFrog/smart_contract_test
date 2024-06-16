// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/RegToken.sol";

contract DeployRegToken is Script {
    function run() external {
        address priceFeed = 0x3c6Cd9Cc7c7a4c2Cf5a82734CD249D7D593354dA; // Replace with actual Chainlink ETH/USD price feed address
        address owner = msg.sender;

        vm.startBroadcast();

        // Deploy the RegToken contract
        RegToken regToken = new RegToken(priceFeed, owner);

        console.log("RegToken deployed at:", address(regToken));

        vm.stopBroadcast();
    }
}
