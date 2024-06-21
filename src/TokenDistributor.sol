// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RegToken.sol";
import "./FishToken.sol";

contract TokenOperations {
    RegToken public regToken;
    FishToken public fishToken;
    address public owner;

    constructor(address _regTokenAddress, address _fishTokenAddress) {
        regToken = RegToken(payable(_regTokenAddress));
        fishToken = FishToken(_fishTokenAddress);
        owner = msg.sender;
    }

    // Modifier: 只有当前 owner 才能调用
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    // 质押1个 REG 代币到合约
    function stakeReg() external {
        require(regToken.balanceOf(msg.sender) >= 1, "Insufficient REG balance to stake");
        regToken.transferFrom(msg.sender, address(this), 1);
    }

    // 归还1个 REG 代币并赠送300个 FISH 代币
    function returnRegAndReward(address recipient) external onlyOwner {
        require(regToken.balanceOf(address(this)) >= 1, "Contract has insufficient REG balance");
        
        regToken.transfer(recipient, 1);
        fishToken.mintOrReward(recipient, 300);
    }

    // 销毁质押的 REG 代币
    function burnReg() external onlyOwner {
        uint256 stakedBalance = regToken.balanceOf(address(this));
        require(stakedBalance >= 3, "Insufficient staked REG balance");

        for (uint256 i = 0; i < 3; i++) {
            regToken.burn(address(this), 1);
        }
    }

    // 转移合约的 owner
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner address cannot be zero address");
        owner = newOwner;
    }



    // 销毁质押的 REG 代币
    function burnStakedReg() external {
        require(msg.sender == owner, "Only owner can perform this action");
        uint256 stakedBalance = regToken.balanceOf(address(this));
        require(stakedBalance >= 3, "Insufficient staked REG balance");

        for (uint256 i = 0; i < 3; i++) {
            regToken.burn(address(this), 1);
        }
    }
}


