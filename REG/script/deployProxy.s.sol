// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../src/MyToken.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "forge-std/Script.sol";

contract DeployUUPSProxy is Script {
    function run() public {

        address _implementation = 0xcDc09938aE056b3AEDA95a44Ff121C6B3cb5f26C; // Replace with your token address
        vm.startBroadcast();

        // Encode the initializer function call
        bytes memory data = abi.encodeWithSelector(
            MyToken(_implementation).initialize.selector,
            msg.sender // Initial owner/admin of the contract
        );

        // Deploy the proxy contract with the implementation address and initializer
        ERC1967Proxy proxy = new ERC1967Proxy(_implementation, data);

        vm.stopBroadcast();
        // Log the proxy address
        console.log("UUPS Proxy Address:", address(proxy));
    }
}

