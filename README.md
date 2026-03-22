## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
# EngileV3

这是一个基于 Foundry 的以太坊智能合约开发示例工程，包含一个简单的 ERC20 代币合约、若干脚本与 broadcast 输出，便于本地测试与链上部署。

**主要内容**

- 合约：`src/Mytoken.sol`（简单的 ERC20 实现）
- 脚本：`script/` 下的部署与演示脚本（例如 `script/DeployToken.s.sol`）
- broadcast：用于记录脚本在各链上执行的输出

**要求**

- Foundry（包含 `forge`, `cast`, `anvil`）

安装 Foundry（如未安装）：

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

快速开始

1. 安装依赖并构建：

```bash
forge build
```

2. 运行单元测试：

```bash
forge test
```

3. 在本地链（anvil）上运行并调试：

```bash
anvil
# 在另一个终端
forge test --fork-url http://localhost:8545
```

部署合约示例

使用 Foundry 脚本部署（示例）：

```bash
forge script script/DeployToken.s.sol:DeployToken --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --broadcast
```

说明：将 `<RPC_URL>` 与 `<PRIVATE_KEY>` 替换为你的节点 RPC 和私钥；`--broadcast` 会把交易发送到指定网络。

合约概览

- `src/Mytoken.sol`：基于 OpenZeppelin 的 `ERC20`，构造函数接受 `name`、`symbol`、`initialSupply`，并将初始代币 mint 给部署者。

脚本与 broadcast

- `script/`：包含用于演示和部署的 Foundry 脚本。
- `broadcast/`：脚本执行时的交易记录（按网络组织），可用于回放或审计部署过程。

脚本（详解）

- `script/DeployToken.s.sol`：部署 `MyToken` 合约（ERC20）。需要环境变量：`PRIVATE_KEY`、`TOKEN_NAME`、`SYMBOL`、`SUPPLY`。

- `script/v2/CreateV2Pair.s.sol`：通过 Uniswap V2 Router/Factory 创建 V2 交易对（若不存在则创建）。需要：`PRIVATE_KEY`、`TOKEN0`、`TOKEN1`。脚本中 router 地址为硬编码示例，请在生产部署前确认或替换。

- `script/v2/AddLiquidityAndBurnLP.s.sol`：向 V2 Router 添加流动性并将 LP token 转入销毁地址（burn）。需要：`PRIVATE_KEY`、`TOKEN0`、`TOKEN1`、`AMOUNT0`、`AMOUNT1`。

- `script/v3/CreatePool.s.sol`：在 Uniswap V3 Factory 上创建池子（示例使用硬编码 FACTORY 地址）。需要：`PRIVATE_KEY`。

- `script/v3/InitPool.s.sol`：对已部署的 V3 池子调用 `initialize`（示例中 pool 地址为硬编码）。需要：`PRIVATE_KEY`。

- `script/v3/AddLiquidity.s.sol`：使用 NonfungiblePositionManager 铸造 V3 NFT LP（mint），需要先 `approve` 代币。需要：`PRIVATE_KEY`、`TOKEN0`、`TOKEN1`（脚本中使用 `TOKEN0/TOKEN1` 环境变量）。

- `script/v3/BurnMintToken.s.sol`：将 V3 的 NFT LP 转移到黑洞地址以“销毁”该 NFT。需要：`PRIVATE_KEY`、`MIN_TOKEN_ID`（要销毁的 tokenId）。

- `script/v4/V4CreatePool.s.sol`：创建 V4 池子并添加流动性（包含初始化、计算 tick、计算 liquidity 并调用 multicall），依赖 `lib/v4-core` 与 `lib/v4-periphery`。需要：`PRIVATE_KEY`、`TOKEN0`、`TOKEN1`、`AMOUNT0`、`AMOUNT1`、`INIT_PRICE`。

重要：许多脚本中对 Factory/Router/PositionManager 等合约地址是硬编码示例，使用前请务必检查并替换为目标网络的正确地址，否则可能发生不可逆的链上操作。

示例 `.env`（参考）

```env
# 基本
PRIVATE_KEY=0x...

# 部署代币
TOKEN_NAME=MyToken
SYMBOL=MTK
SUPPLY=1000000

# V2/V3/V4 脚本示例
TOKEN0=0x... # e.g. USDT
TOKEN1=0x... # e.g. WETH
AMOUNT0=1000
AMOUNT1=1
INIT_PRICE=100
MIN_TOKEN_ID=1234
```

运行脚本示例（带广播）

```bash
# 部署 ERC20
forge script script/DeployToken.s.sol:Deploy --rpc-url <RPC_URL> --private-key $PRIVATE_KEY --broadcast

# 创建 V2 交易对
forge script script/v2/CreateV2Pair.s.sol:CreateV2Pair --rpc-url <RPC_URL> --private-key $PRIVATE_KEY --broadcast

# 在 V4 上创建并添加流动性（示例）
forge script script/v4/V4CreatePool.s.sol:V4CreatePoolAndAddLiquidity --rpc-url <RPC_URL> --private-key $PRIVATE_KEY --broadcast
```

配置

项目根目录的 `foundry.toml` 已配置 `src`、`out`、`lib` 等常用项，并通过 remappings 引入了本地依赖（如 `lib/v2-core`、`lib/v2-periphery`）。如需新增 remapping，可编辑 `foundry.toml`。

常用命令速查

- 构建：`forge build`
- 测试：`forge test`
- 格式化：`forge fmt`
- 本地节点：`anvil`
- 与链交互：`cast`

贡献

欢迎通过 PR 提交改进：

- 新增合约或脚本请放入 `src/` 或 `script/`。
- 测试放在 `test/`。

许可证

本仓库使用 MIT 许可证（合同源码头部包含 SPDX 许可声明）。

----

如果你想要我把 README 翻译为英文、补充更详细的部署示例（例如针对以太坊主网、Goerli、Sepolia、或使用第三方 RPC 的步骤），或直接把部署脚本示例填充进 `script/DeployToken.s.sol`，告诉我你想要的网络与私钥管理方式，我可以继续完善。
