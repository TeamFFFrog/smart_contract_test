// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RegToken.sol";
import "./FishToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenOperations is Ownable {
    RegToken public regToken;
    FishToken public fishToken;

    constructor(
        address _regTokenAddress,
        address _fishTokenAddress,
        address _owner
    ) Ownable(_owner) {
        regToken = RegToken(payable(_regTokenAddress));
        fishToken = FishToken(_fishTokenAddress);
    }

    // 质押1个 REG 代币到合约
    function stakeReg() external {
        require(regToken.balanceOf(msg.sender) >= 1, "Insufficient REG balance to stake");
        regToken.transferFrom(msg.sender, address(this), 1);
    }

    // 归还1个 REG 代币并赠送300个 FISH 代币，只有 owner 可调用
    function returnRegAndReward(address recipient) external onlyOwner {
        require(regToken.balanceOf(address(this)) >= 1, "Contract has insufficient REG balance");
        
        regToken.transfer(recipient, 1);
        fishToken.mintOrReward(recipient, 300);
    }

    // 销毁质押的 REG 代币，只有 owner 可调用
    function burnStakedReg() external onlyOwner {
        uint256 stakedBalance = regToken.balanceOf(address(this));
        require(stakedBalance >= 3, "Insufficient staked REG balance");

        for (uint256 i = 0; i < 3; i++) {
            regToken.burn(address(this), 1);
        }
    }

    // 转移合约的 owner，只有当前 owner 可调用
    function transferOwnership(address newOwner) public override onlyOwner {
        require(newOwner != address(0), "New owner address cannot be zero address");
        super.transferOwnership(newOwner);
    }
}

