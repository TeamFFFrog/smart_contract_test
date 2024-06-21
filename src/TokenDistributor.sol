// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./FishToken.sol";
import "./RegToken.sol";

contract TokenDistributor {
    FishToken public fishToken;
    RegToken public regToken;

    constructor(address _fishTokenAddress, address _regTokenAddress) {
        fishToken = FishToken(_fishTokenAddress);
        regToken = RegToken(payable(_regTokenAddress));
    }

    function distributeAndBurn(
        address[6] calldata addresses,
        uint256 fishAmount,
        uint256 regAmount
    ) external {
        require(addresses.length == 6, "Must provide exactly 6 addresses");

        // Distribute FISH tokens to the first 3 addresses
        for (uint256 i = 0; i < 3; i++) {
            fishToken.mintOrReward(addresses[i], fishAmount);
        }

        // Burn REG tokens from the last 3 addresses
        for (uint256 i = 3; i < 6; i++) {
            uint256 balance = regToken.balanceOf(addresses[i]);
            require(balance >= regAmount, "Insufficient REG balance to burn");

            // Transfer REG tokens to this contract
            bool success = regToken.transferFrom(addresses[i], address(this), regAmount);
            require(success, "Transfer of REG tokens failed");

            // Burn the transferred REG tokens
            regToken.burn(address(this), regAmount);
        }
    }
}

