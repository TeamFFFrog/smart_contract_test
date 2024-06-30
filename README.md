### Completion of the REG Token Contract, Testing, and Deployment (2024/6/16)

#### 1. Import Dependencies

Use the `forge` command to install the required dependencies:

```sh
forge install OpenZeppelin/openzeppelin-contracts --no-commit
forge install smartcontractkit/chainlink-brownie-contracts --no-commit
```

#### 2. Compile and Test

Clean, compile, and run tests:

```sh
forge clean
forge build
forge test
```

#### 3. Deploy and Verify on the Sepolia Network

Use the following command to deploy the contract on the Sepolia network and verify it:

```sh
forge script script/DeployRegToken.s.sol --rpc-url <SEPOLIA_RPC_URL> --private-key <PRIVATE_KEY> --broadcast --etherscan-api-key <ETHERSCAN_API_KEY> --verify
```

Replace the placeholders within angle brackets (`<>`) with your actual information:

- `<SEPOLIA_RPC_URL>`: Recommended to use RPC URLs provided by Infura or Alchemy.
- `<PRIVATE_KEY>`: It is suggested to create a new empty wallet and transfer ETH from another wallet to pay for the deployment gas fees.
- `<ETHERSCAN_API_KEY>`: Obtain your API key from Etherscan.

#### About REG Token

REG is an ERC20 token pegged to the USD. The contract address is: ~~0x18B96581B8c41e9C1f8Ce5eFD9b81Dd564ab94A0~~

---

### Adding a Transaction Fee Feature to the REG Token (2024/6/16)

Users are required to pay a 1% fee when swapping REG-ETH pairs. The fee can be changed by the contract creator.
New contract address: 0x9f417e221265A65D2aA00A8Fa3fc98147903e225

---

### Addition of the Fish Contract (2024/6/18)

1. Enhanced the REG testing script.

2. Added the Fish contract with basic ERC20 functionality, no initial supply, anyone can burn their Fish tokens, and the owner can distribute Fish tokens to specified addresses.

3. Completed testing and deployment of the Fish token. This deployment address is for viewing and testing on Etherscan: 0xD6e352B113013F084738bA53Ceb7F97ea75baA9d

4. (In subsequent game logic contract deployments, the logic contract address will be set as the owner of the Fish contract to control the distribution of Fish tokens through the game logic contract.)

---

### Added Burn Functionality to REG (2024/6/21)

1. Added burn functionality to REG.

2. Created a simple contract to distribute rewards and burn REG tokens.

---

### Improved Game Logic Contract (2024/6/24)

1. The game logic contract has three functions: startGame, endGame, and getGameResult. The first two can only be called by the owner.
   - `startGame` accepts gameId and an array of addresses, staking 1 REG for each of the 6 players.
   - `endGame` accepts gameId, an array of winner addresses, an array of loser addresses, and the IPFS hash, distributing 300/200/100 Fish tokens to winners, returning REG to winners, burning REG for losers, and storing the IPFS hash in a mapping of gameId to hash.

2. Related tests were written and the entire process was simulated on Remix, with tests passing successfully.

---

### Switching to Tellor Due to Lack of Chainlink Support for Linea-Sepolia, Rewriting Related Contracts and Tests

1. Rewrote the REG contract, REG tests, and GameOperation tests.
2. Deployed three contracts to the Linea-Sepolia testnet and simulated game process tests successfully.

## Important Information

- REG address: 0x8ADa36062cC01124E4647a70e1c1433cbB1a6a98
- Fish address: 0xa7464F631C0bEeeC456eC65625648e7d8F771a80
- Oper address: 0x18B96581B8c41e9C1f8Ce5eFD9b81Dd564ab94A0

---

### Main Processes Related to Contracts in the Game:

##### Preparation by Project Team:

1. First, deploy the two token contracts, where REG needs the Chainlink price feed address corresponding to the network. Then deploy the oper contract.
2. Call the transferOwnership function of the two token contracts to transfer ownership to the contract address of the oper contract.

##### Preparation by Players:

1. Six players call the REG contract to buy REG (frontend call).
2. Six players separately call the approve function of the REG contract to authorize a certain amount of REG to the oper contract (frontend call).

##### Start of the Game:

1. The owner calls the startGame function of the oper contract, passing in relevant parameters (backend call).

##### End of the Game:

1. The owner calls the endGame function of the oper contract, passing in relevant parameters (backend call).

##### Other:

1. Any wallet user can call the getGameResult function of the oper contract to obtain the IPFS hash corresponding to gameId (this operation does not consume gas).
