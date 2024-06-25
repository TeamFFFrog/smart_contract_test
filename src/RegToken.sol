// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../lib/usingtellor/contracts/UsingTellor.sol";

contract RegToken is ERC20, Ownable, UsingTellor {
    bytes public queryData = abi.encode("SpotPrice", abi.encode("eth", "usd"));
    bytes32 public queryId = keccak256(queryData);
    uint256 public feeRate; // Fee rate in basis points (e.g., 100 = 1%)
    uint256 public lastStoredTimestamp; // Cache timestamp to prevent dispute attacks
    uint256 public lastStoredPrice;

    event FeeRateChanged(uint256 newFeeRate);
    event Regamount(uint256 regAmount);

    // Using Tellor's ETH/USD price feed
    constructor(
        address payable _tellorAddress,
        address initialOwner,
        uint256 _feeRate
    )
        ERC20("Reg Token", "REG")
        Ownable(initialOwner)
        UsingTellor(_tellorAddress)
    {
        feeRate = _feeRate;
    }

    /**
     * Returns the latest price from Tellor
     */
    function getLatestPrice()
        public
        returns (uint256 _price, uint256 timestamp)
    {
        // Retrieve data at least 15 minutes old to allow time for disputes
        (bytes memory _value, uint256 _timestampRetrieved) = getDataBefore(
            queryId,
            block.timestamp - 15 minutes
        );
        require(_timestampRetrieved > 0, "No price data found");
        // Check that the data is not too old
        require(
            block.timestamp - _timestampRetrieved < 24 hours,
            "Price data too old"
        );

        // decode the value from bytes to uint256
        _price = abi.decode(_value, (uint256));

        // prevent a back-in-time dispute attack by caching the most recent value and timestamp.
        // this stops an attacker from disputing tellor values to manupulate which price is used
        // by your protocol
        if (_timestampRetrieved > lastStoredTimestamp) {
            // if the new value is newer than the last stored value, update the cache
            lastStoredTimestamp = _timestampRetrieved;
            lastStoredPrice = _price;
        } else {
            // if the new value is older than the last stored value, use the cached value
            _price = lastStoredPrice;
            _timestampRetrieved = lastStoredTimestamp;
        }
        // return the value and timestamp
        return (_price, _timestampRetrieved);
    }

    // Calculate the amount of REG tokens for given ETH amount
    function calculateRegAmount(uint256 ethAmount) public returns (uint256) {
        (uint256 ethPrice, ) = getLatestPrice();
        return (ethAmount * ethPrice) / 1e18;
    }

    // Calculate the amount of ETH for given REG tokens
    function calculateEthAmount(uint256 regAmount) public returns (uint256) {
        (uint256 ethPrice, ) = getLatestPrice();
        return ((regAmount * 1e18) / ethPrice);
    }

    // Buy Reg tokens with ETH, deducting fee
    function buyRegTokens() public payable {
        require(msg.value > 0, "Must send ETH to buy REG tokens");
        uint256 fee = (msg.value * feeRate) / 100;
        uint256 netEthAmount = msg.value - fee;
        uint256 regAmount = calculateRegAmount(netEthAmount);
        _mint(msg.sender, regAmount);
    }

    // Sell Reg tokens for ETH, deducting fee
    function sellRegTokens(uint256 regAmount) public {
        require(balanceOf(msg.sender) >= regAmount, "Insufficient REG balance");
        uint256 ethAmount = calculateEthAmount(regAmount);
        uint256 fee = (ethAmount * feeRate) / 100;
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

    // Allow the owner to burn tokens from any address
    function burnFrom(address account, uint256 amount) public onlyOwner {
        _burn(account, amount);
    }

    // Receive ETH to the contract
    receive() external payable {}
}
