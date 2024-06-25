// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/RegToken.sol";
import "../src/FishToken.sol";
import "../src/GameOperations.sol";
import "../lib/usingtellor/contracts/UsingTellor.sol";
import {TellorPlayground} from "../lib/usingtellor/contracts/TellorPlayground.sol";

contract GameOperationsTest is Test {
    RegToken public regToken;
    FishToken public fishToken;
    GameOperations public gameOperations;
    TellorPlayground public tellorPlayground;

    bytes public queryData = abi.encode("SpotPrice", abi.encode("eth", "usd"));
    bytes32 public queryId = keccak256(queryData);

    address owner = address(0xABCD);
    address player1 = address(0x1234);
    address player2 = address(0x5678);
    address player3 = address(0x9ABC);
    address player4 = address(0xDEF0);
    address player5 = address(0x1357);
    address player6 = address(0x2468);

    function setUp() public {
        // Set up initial conditions
        // Deploy TellorPlayground and set initial price
        vm.startPrank(owner);
        tellorPlayground = new TellorPlayground();
        uint256 mockValue = 2000e18;
        tellorPlayground.submitValue(
            queryId,
            abi.encodePacked(mockValue),
            0,
            queryData
        );
        regToken = new RegToken(payable(address(tellorPlayground)), owner, 1);
        fishToken = new FishToken(owner);
        gameOperations = new GameOperations(
            address(regToken),
            address(fishToken),
            owner
        );

        // Transfer ownership of FishToken to GameOperations contract
        fishToken.transferOwnership(address(gameOperations));
        regToken.transferOwnership(address(gameOperations));
        vm.stopPrank();
        // Fund the owner and players with ETH
        vm.deal(owner, 10 ether);
        vm.deal(player1, 10 ether);
        vm.deal(player2, 10 ether);
        vm.deal(player3, 10 ether);
        vm.deal(player4, 10 ether);
        vm.deal(player5, 10 ether);
        vm.deal(player6, 10 ether);

        // Players buy REG tokens with ETH and approve GameOperations contract
        buyAndApproveRegTokens(player1);
        buyAndApproveRegTokens(player2);
        buyAndApproveRegTokens(player3);
        buyAndApproveRegTokens(player4);
        buyAndApproveRegTokens(player5);
        buyAndApproveRegTokens(player6);

        // Ensure the initial price data is valid
        vm.warp(block.timestamp + 901 seconds); // Warp to a time past the initial data's timestamp
    }

    function buyAndApproveRegTokens(address player) internal {
        vm.warp(block.timestamp + 905 seconds); // Warp the block timestamp to ensure price data is not stale
        vm.startPrank(player);
        regToken.buyRegTokens{value: 1 ether}();
        regToken.approve(address(gameOperations), 1 * 10 ** 18);
        vm.stopPrank();
    }

    function testStartGame() public {
        address[] memory players = new address[](6);
        players[0] = player1;
        players[1] = player2;
        players[2] = player3;
        players[3] = player4;
        players[4] = player5;
        players[5] = player6;

        vm.startPrank(owner);
        gameOperations.startGame(1, players);
        vm.stopPrank();

        // Check that the contract has 6 REG tokens
        uint256 contractBalance = regToken.balanceOf(address(gameOperations));
        assertEq(
            contractBalance,
            6 * 10 ** 18,
            "Contract should have 6 REG tokens"
        );

        // Check that players' balances have been reduced by 1 REG token
        for (uint256 i = 0; i < players.length; i++) {
            uint256 playerBalance = regToken.balanceOf(players[i]);
            uint256 initialBalance = (regToken.calculateRegAmount(1 ether) *
                99) / 100; // Considering 1% fee
            assertEq(
                playerBalance,
                initialBalance - 1 * 10 ** 18,
                "Player should have correct REG balance after staking"
            );
        }
    }

    function testEndGame() public {
        address[] memory players = new address[](6);
        players[0] = player1;
        players[1] = player2;
        players[2] = player3;
        players[3] = player4;
        players[4] = player5;
        players[5] = player6;

        vm.startPrank(owner);
        gameOperations.startGame(1, players);
        vm.stopPrank();

        address[] memory winners = new address[](3);
        winners[0] = player1;
        winners[1] = player2;
        winners[2] = player3;

        address[] memory losers = new address[](3);
        losers[0] = player4;
        losers[1] = player5;
        losers[2] = player6;

        string memory ipfsHash = "Qm..."; // Example IPFS hash

        vm.startPrank(owner); // Ensure the call to endGame is made by the owner
        gameOperations.endGame(1, winners, losers, ipfsHash);
        vm.stopPrank();

        // Check winners' balances
        uint256[] memory rewards = new uint256[](3);
        rewards[0] = 300;
        rewards[1] = 200;
        rewards[2] = 100;

        for (uint256 i = 0; i < winners.length; i++) {
            uint256 playerBalance = fishToken.balanceOf(winners[i]);
            assertEq(
                playerBalance,
                rewards[i] * 10 ** 18,
                "Winner should have correct FISH reward"
            );
            uint256 regBalance = regToken.balanceOf(winners[i]);
            uint256 initialBalance = (regToken.calculateRegAmount(1 ether) *
                99) / 100; // Considering 1% fee
            assertEq(
                regBalance,
                initialBalance,
                "Winner should have their REG token returned"
            );
        }

        // Check losers' balances
        for (uint256 i = 0; i < losers.length; i++) {
            uint256 regBalance = regToken.balanceOf(losers[i]);
            uint256 initialBalance = (regToken.calculateRegAmount(1 ether) *
                99) / 100; // Considering 1% fee
            uint256 expectedBalance = initialBalance - 1 * 10 ** 18;
            assertEq(
                regBalance,
                expectedBalance,
                "Loser should have lost their staked REG token"
            );
        }

        // Check stored game result
        string memory storedIpfsHash = gameOperations.getGameResult(1);
        assertEq(storedIpfsHash, ipfsHash, "Stored IPFS hash should match");
    }
}
