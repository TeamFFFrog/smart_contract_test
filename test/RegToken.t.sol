// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/RegToken.sol";
import "@chainlink/contracts/v0.8/interfaces/AggregatorV3Interface.sol";

contract MockPriceFeed is AggregatorV3Interface {
    int256 private price;

    function setPrice(int256 _price) external {
        price = _price;
    }

    function latestRoundData()
        public
        view
        override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return (0, price, 0, 0, 0);
    }

    function decimals() external pure override returns (uint8) {
        return 8;
    }

    function description() external pure override returns (string memory) {
        return "Mock Price Feed";
    }

    function version() external pure override returns (uint256) {
        return 1;
    }

    function getRoundData(
        uint80 _roundId
    )
        external
        pure
        override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return (_roundId, 0, 0, 0, 0);
    }
}

contract RegTokenTest is Test {
    RegToken public regToken;
    MockPriceFeed public mockPriceFeed;

    address owner = address(0xABCD);
    address user = address(0x1234);

    function setUp() public {
        // Deploy MockPriceFeed and set initial price
        mockPriceFeed = new MockPriceFeed();
        mockPriceFeed.setPrice(3000 * 10 ** 8); // Set price to 3000 USD

        // Deploy RegToken contract
        regToken = new RegToken(address(mockPriceFeed), owner);

        // Fund the contract with ETH to support token selling
        vm.deal(address(regToken), 1 ether);

        // Label addresses for better readability
        vm.label(owner, "Owner");
        vm.label(user, "User");
    }

    function testGetLatestPrice() public view {
        int256 price = regToken.getLatestPrice();
        assertEq(price, 3000 * 10 ** 8, "Price should be 3000 USD");
    }

    function testBuyRegTokens() public {
        vm.deal(user, 1 ether); // Fund user with 1 ETH

        vm.prank(user);
        regToken.buyRegTokens{value: 0.01 ether}();

        uint256 regBalance = regToken.balanceOf(user);
        assertEq(regBalance, 3000, "User should have 3000 REG tokens");
    }

    function testSellRegTokens() public {
        vm.deal(user, 1 ether); // Fund user with 1 ETH

        vm.prank(user);
        regToken.buyRegTokens{value: 0.01 ether}();

        uint256 regBalance = regToken.balanceOf(user);
        assertEq(regBalance, 3000, "User should have 3000 REG tokens");

        vm.prank(user);
        regToken.sellRegTokens(3000);

        regBalance = regToken.balanceOf(user);
        assertEq(regBalance, 0, "User should have 0 REG tokens");

        uint256 ethBalance = user.balance;
        assertEq(ethBalance, 1 ether, "User should have 1 ETH back");
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
}