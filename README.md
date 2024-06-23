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

REG 是一种 ERC20 代币，其价格与美元绑定。合约地址为：~~0x18B96581B8c41e9C1f8Ce5eFD9b81Dd564ab94A0~~

### 增加 REG 代币交易手续费功能（2024/6/16）

用户在交换 REG-ETH 币对时需付 1%手续费，手续费可由合约创建者更改。
新合约地址：0x9f417e221265A65D2aA00A8Fa3fc98147903e225

### 新增 Fish 合约（2024/6/18）

1. 完善了 REG 测试脚本

2. 新增 Fish 合约，具备基础 ERC20 功能，无初始供应，任何人可以销毁自己的 Fish 代币，owner 可以发放 Fish 币给指定地址

3. 完成 Fish 币的测试和部署，此部署地址仅为大家在 EtherScan 上查看、测试用：0xD6e352B113013F084738bA53Ceb7F97ea75baA9d

4. （在后续的游戏逻辑合约部署时，将逻辑合约地址作为 Fish 合约的 owner，来实现通过游戏逻辑合约控制 Fish 币的分发）

### REG加了burn功能（2024/6/21）

1. REG加了burn功能

2. 简单地写了个分配奖励和燃烧REG的合约
   
