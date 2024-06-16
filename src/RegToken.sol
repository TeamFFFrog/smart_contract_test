// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/v0.8/interfaces/AggregatorV3Interface.sol";

contract RegToken is ERC20, Ownable {
    AggregatorV3Interface internal priceFeed;
    uint256 public feeRate; // Fee rate in basis points (e.g., 100 = 1%)

    event FeeRateChanged(uint256 newFeeRate);

    // Using Chainlink's ETH/USD price feed
    constructor(
        address _priceFeed,
        address initialOwner,
        uint256 _feeRate
    ) ERC20("Reg Token", "REG") Ownable(initialOwner) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        feeRate = _feeRate;
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int) {
        (
            ,
            /*uint80 roundID*/ int price /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/,
            ,
            ,

        ) = priceFeed.latestRoundData();
        return price;
    }

    // Calculate the amount of REG tokens for given ETH amount
    function calculateRegAmount(
        uint256 ethAmount
    ) public view returns (uint256) {
        int price = getLatestPrice();
        require(price > 0, "Invalid price feed");
        uint256 ethPrice = uint256(price);
        // Assume 1 REG = 0.01 ETH (1 ETH = 100 REG)
        return (ethAmount * ethPrice) / (0.01 ether * 1e8);
    }

    // Calculate the amount of ETH for given REG tokens
    function calculateEthAmount(
        uint256 regAmount
    ) public view returns (uint256) {
        int price = getLatestPrice();
        require(price > 0, "Invalid price feed");
        uint256 ethPrice = uint256(price);
        // Assume 1 REG = 0.01 ETH (1 ETH = 100 REG)
        return (regAmount * (0.01 ether * 1e8)) / ethPrice;
    }

    // Buy Reg tokens with ETH, deducting fee
    function buyRegTokens() public payable {
        require(msg.value > 0, "Must send ETH to buy REG tokens");
        uint256 fee = (msg.value * feeRate) / 10000;
        uint256 netEthAmount = msg.value - fee;
        uint256 regAmount = calculateRegAmount(netEthAmount);
        _mint(msg.sender, regAmount);
    }

    // Sell Reg tokens for ETH, deducting fee
    function sellRegTokens(uint256 regAmount) public {
        require(balanceOf(msg.sender) >= regAmount, "Insufficient REG balance");
        uint256 ethAmount = calculateEthAmount(regAmount);
        uint256 fee = (ethAmount * feeRate) / 10000;
        uint256 netEthAmount = ethAmount - fee;
        require(
            address(this).balance >= netEthAmount,
            "Insufficient ETH balance in contract"
        );
        _burn(msg.sender, regAmount);
        payable(msg.sender).transfer(netEthAmount);
    }

    // Withdraw ETH from the contract (only owner)
    function withdrawETH(uint256 amount) public onlyOwner {
        require(address(this).balance >= amount, "Insufficient ETH balance");
        payable(owner()).transfer(amount);
    }

    // Update fee rate (only owner)
    function updateFeeRate(uint256 newFeeRate) public onlyOwner {
        feeRate = newFeeRate;
        emit FeeRateChanged(newFeeRate);
    }

    // Receive ETH to the contract
    receive() external payable {}
}
