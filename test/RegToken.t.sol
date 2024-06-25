// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/RegToken.sol";
import "../lib/usingtellor/contracts/UsingTellor.sol";
import {TellorPlayground} from "../lib/usingtellor/contracts/TellorPlayground.sol";

contract RegTokenTest is Test {
    RegToken public regToken;
    TellorPlayground public tellorPlayground;

    bytes public queryData = abi.encode("SpotPrice", abi.encode("eth", "usd"));
    bytes32 public queryId = keccak256(queryData);

    address owner = address(0xABCD);
    address user = address(0x1234);

    function setUp() public {
        // Deploy TellorPlayground and set initial price
        tellorPlayground = new TellorPlayground();
        uint256 mockValue = 2000e18;
        tellorPlayground.submitValue(
            queryId,
            abi.encodePacked(mockValue),
            0,
            queryData
        );

        // Deploy RegToken contract
        regToken = new RegToken(payable(address(tellorPlayground)), owner, 1); // Fee rate is 1%

        // Fund the contract with ETH to support token selling
        vm.deal(address(regToken), 1 ether);

        // Label addresses for better readability
        vm.label(owner, "Owner");
        vm.label(user, "User");

        // Ensure the initial price data is valid
        vm.warp(block.timestamp + 901 seconds); // Warp to a time past the initial data's timestamp
    }

    function test_ReadETHPrice() public {
        (uint256 ethPrice, ) = regToken.getLatestPrice();
        assertEq(ethPrice, 2000e18);
    }

    function testGetLatestPrice() public {
        (uint256 price, ) = regToken.getLatestPrice();
        assertEq(price, 2000e18, "Price should be 2000 USD");
    }

    function testcaculatereg() public {
        vm.deal(user, 1 ether); // Fund user with 1 ETH
        vm.prank(user);
        uint256 amount = regToken.calculateRegAmount(1e16);
        assertEq(amount, 20 * 1e18, "wrong amount");
    }

    function testBuyRegTokens() public {
        vm.deal(user, 1 ether); // Fund user with 1 ETH

        // Ensure the price is set and sufficient time has passed
        uint256 mockValue = 2000e18;
        tellorPlayground.submitValue(
            queryId,
            abi.encodePacked(mockValue),
            0,
            queryData
        );
        vm.warp(block.timestamp + 905 seconds); // Warp the block timestamp to ensure price data is not stale

        vm.prank(user);
        regToken.buyRegTokens{value: 0.1 ether}();
        uint256 regBalance = regToken.balanceOf(user);
        // Deduct 1% fee from 0.1 ether, so net ETH is 0.099 ether
        vm.warp(block.timestamp + 905 seconds);
        uint256 expectedRegAmount = regToken.calculateRegAmount(0.099 ether);
        assertEq(
            regBalance,
            expectedRegAmount,
            "User should have correct REG tokens"
        );
    }

    function testSellRegTokens() public {
        vm.deal(user, 1 ether); // Fund user with 1 ETH

        // Ensure the price is set and sufficient time has passed
        uint256 mockValue = 2000e18;
        tellorPlayground.submitValue(
            queryId,
            abi.encodePacked(mockValue),
            0,
            queryData
        );
        vm.warp(block.timestamp + 15 minutes + 1 seconds); // Warp the block timestamp to ensure price data is not stale

        vm.prank(user);
        regToken.buyRegTokens{value: 0.1 ether}();

        uint256 regBalance = regToken.balanceOf(user);
        // Deduct 1% fee from 0.1 ether, so net ETH is 0.099 ether
        uint256 expectedRegAmount = regToken.calculateRegAmount(0.099 ether);
        assertEq(
            regBalance,
            expectedRegAmount,
            "User should have correct REG tokens"
        );

        vm.prank(user);
        regToken.sellRegTokens(expectedRegAmount);

        regBalance = regToken.balanceOf(user);
        assertEq(regBalance, 0, "User should have 0 REG tokens");

        // User should have received ETH minus fee
        uint256 expectedEthAmount = regToken.calculateEthAmount(
            expectedRegAmount
        );
        uint256 fee = expectedEthAmount / 100; // 1% fee in basis points
        uint256 netEthAmount = expectedEthAmount - fee;
        uint256 ethBalance = user.balance;
        assertEq(
            ethBalance,
            netEthAmount + 0.9 ether,
            "User should have correct ETH back"
        ); // Initial ETH - 0.1 ETH + netEthAmount
    }

    function testWithdrawETH() public {
        vm.deal(address(regToken), 1 ether); // Fund contract with 1 ETH

        uint256 contractBalance = address(regToken).balance;
        assertEq(contractBalance, 1 ether, "Contract should have 1 ETH");

        vm.prank(owner);
        regToken.withdrawETH(0.5 ether);

        contractBalance = address(regToken).balance;
        assertEq(contractBalance, 0.5 ether, "Contract should have 0.5 ETH");

        uint256 ownerBalance = owner.balance;
        assertEq(ownerBalance, 0.5 ether, "Owner should have 0.5 ETH");
    }

    function testUpdateFeeRate() public {
        uint256 newFeeRate = 200; // 2%
        vm.prank(owner);
        regToken.updateFeeRate(newFeeRate);

        assertEq(
            regToken.feeRate(),
            newFeeRate,
            "Fee rate should be updated to 2%"
        );
    }

    function testOnlyOwnerCanUpdateFeeRate() public {
        uint256 newFeeRate = 200; // 2%
        vm.prank(user);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                user
            )
        );
        regToken.updateFeeRate(newFeeRate);
    }

    function testOnlyOwnerCanWithdrawETH() public {
        vm.prank(user);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                user
            )
        );
        regToken.withdrawETH(0.5 ether);
    }
}
