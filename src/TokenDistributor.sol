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

    // 归还1个 REG 代币并赠送300个 FISH 代币，每个地址归还给一个不同的接收者
    function returnRegAndReward(
        address recipient1,
        address recipient2,
        address recipient3
    ) external onlyOwner {
        require(regToken.balanceOf(address(this)) >= 3, "Contract has insufficient REG balance");

        // 分别向三个不同地址归还 REG 代币
        regToken.transfer(recipient1, 1);
        regToken.transfer(recipient2, 1);
        regToken.transfer(recipient3, 1);

        // 向每个地址赠送300个 FISH 代币
        fishToken.mintOrReward(recipient1, 300);
        fishToken.mintOrReward(recipient2, 300);
        fishToken.mintOrReward(recipient3, 300);
    }

    // 销毁质押的3个 REG 代币，每个地址销毁自己的质押
    function burnStakedReg(
        address staker1,
        address staker2,
        address staker3
    ) external onlyOwner {
        require(regToken.balanceOf(address(this)) >= 3, "Contract has insufficient staked REG balance");

        // 分别销毁三个不同地址的质押
        regToken.burn(staker1, 1);
        regToken.burn(staker2, 1);
        regToken.burn(staker3, 1);
    }

    // 转移合约的 owner，只有当前 owner 可调用
    function transferOwnership(address newOwner) public override onlyOwner {
        require(newOwner != address(0), "New owner address cannot be zero address");
        super.transferOwnership(newOwner);
    }
}


