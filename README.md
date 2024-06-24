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

---

### 增加 REG 代币交易手续费功能（2024/6/16）

用户在交换 REG-ETH 币对时需付 1%手续费，手续费可由合约创建者更改。
新合约地址：0x9f417e221265A65D2aA00A8Fa3fc98147903e225

---

### 新增 Fish 合约（2024/6/18）

1. 完善了 REG 测试脚本

2. 新增 Fish 合约，具备基础 ERC20 功能，无初始供应，任何人可以销毁自己的 Fish 代币，owner 可以发放 Fish 币给指定地址

3. 完成 Fish 币的测试和部署，此部署地址仅为大家在 EtherScan 上查看、测试用：0xD6e352B113013F084738bA53Ceb7F97ea75baA9d

4. （在后续的游戏逻辑合约部署时，将逻辑合约地址作为 Fish 合约的 owner，来实现通过游戏逻辑合约控制 Fish 币的分发）

---

### REG 加了 burn 功能（2024/6/21）

1. REG 加了 burn 功能

2. 简单地写了个分配奖励和燃烧 REG 的合约

---

### 改进游戏逻辑合约（2024/6/24）

1. 游戏逻辑合约有 startGame、endGame、getGameResult 三个函数，前两个只允许 owner 调用。
   startGame 会接受 gameId 和一个地址数组，质押 6 名玩家每名 1 个 REG；endGame 会接受 gameId、赢家地址数组、输家地址数组和 IPFS 的 hash，并分发给赢家 300/200/100 fish 币且返还 REG，销毁输家 REG，将 IPFS 的 hash 存入 gameId=>hash 的映射中

2. 编写了相关测试，并在 Remix 上模拟了全过程，测试无误

---

## 一些重要信息

REG 地址：0x0769a90bea3121599DA6b48eD5fBdE47ABd83EBE
fish 地址：0xf94aa9537CfA0E4d21F8e41457326A57fb1368aC
oper 地址：0x9C709D42f87A9FCFA2B8b75B908609d9F5A93C57

目前部署在以太坊的 sepolia 链，若后续无更改，可部署到 linea-sepolia 链

---

### 游戏中与合约相关的主要流程：

##### 项目方事先准备：

1. 先部署两个币合约，其中 REG 需要对应网的 chainlink 喂价地址；再部署 oper 合约
2. 调用两个币合约的 transferOwnership 函数，将 owner 转移给 oper 合约的合约地址

##### 玩家事先准备：

1. 6 个玩家调用 REG 合约买 REG
2. 6 个玩家分别调用 REG 的 approve 函数向 oper 合约授权一定数量的 REG（前端实现）

##### 游戏开始：

1. owner 调用 oper 合约的 startGame，传入相关参数（后端实现）

##### 游戏结束：

1. owner 调用 oper 合约的 endGame，传入相关参数（后端实现）

##### 其他：

1. 任何钱包用户调用 oper 合约的 getGameResult 获取对应 gameId 的 IPFS 的 hash（此操作不消耗 gas）
