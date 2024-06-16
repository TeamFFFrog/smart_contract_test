### 完成 REG 代币的合约、测试和部署（2024/6/16）

#### 1. 导入依赖项

使用 `forge` 命令安装所需的依赖项：

```sh
forge install OpenZeppelin/openzeppelin-contracts --no-commit
forge install smartcontractkit/chainlink-brownie-contracts --no-commit
```

#### 2. 编译和测试

清理、编译并运行测试：

```sh
forge clean
forge build
forge test
```

#### 3. 在 Sepolia 网络部署并验证

使用以下命令在 Sepolia 网络上部署合约并进行验证：

```sh
forge script script/DeployRegToken.s.sol --rpc-url <SEPOLIA_RPC_URL> --private-key <PRIVATE_KEY> --broadcast --etherscan-api-key <ETHERSCAN_API_KEY> --verify
```

请将尖括号 (`<>`) 内的占位符替换为您的实际信息：

- `<SEPOLIA_RPC_URL>`：推荐使用 Infura 或 Alchemy 提供的 RPC URL。
- `<PRIVATE_KEY>`：建议新建一个空钱包，并从其他钱包转入 ETH 以支付部署时的 Gas 费用。
- `<ETHERSCAN_API_KEY>`：从 Etherscan 获取您的 API 密钥。

#### 关于 REG 代币

REG 是一种 ERC20 代币，其价格与 ETH 按 100:1 绑定。合约地址为：`0x18B96581B8c41e9C1f8Ce5eFD9b81Dd564ab94A0`。
