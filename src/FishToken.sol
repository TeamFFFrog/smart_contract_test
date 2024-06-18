// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FishToken is ERC20, Ownable {
    uint256 public constant INITIAL_SUPPLY = 1000000 * 10 ** 18;

    constructor(
        address initialOwner
    ) ERC20("Fish Token", "FISH") Ownable(initialOwner) {
        _mint(initialOwner, INITIAL_SUPPLY);
    }

    // Mint new Fish tokens
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // Burn Fish tokens
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    // Reward function to distribute Fish tokens
    function reward(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
