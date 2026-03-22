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
# EngileV3

EngileV3 is a Foundry-based example project for Ethereum smart contract development. It includes a simple ERC20 token, multiple deployment/demo scripts for Uniswap V2/V3/V4 flows, and recorded `broadcast/` outputs to inspect transactions.

Key contents

- Contracts: `src/Mytoken.sol` — a minimal ERC20 token (OpenZeppelin-based).
- Scripts: `script/` — deployment and demo scripts (V2/V3/V4 and token deploy).
- Broadcasts: `broadcast/` — saved outputs from script executions organized by network.

Requirements

- Foundry (forge, cast, anvil). Install with:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

Quickstart

1. Build the project:

```bash
forge build
```

2. Run tests:

```bash
forge test
```

3. Run a local node for manual testing:

```bash
anvil
# in another terminal
forge test --fork-url http://localhost:8545
```

Scripts overview

The `script/` directory contains Foundry scripts used to deploy contracts and perform liquidity operations on Uniswap V2/V3/V4-like systems. Most scripts read configuration from environment variables via `vm.env*`.

- `script/DeployToken.s.sol` — Deploys `MyToken` (ERC20). Required env vars: `PRIVATE_KEY`, `TOKEN_NAME`, `SYMBOL`, `SUPPLY`.

- `script/v2/CreateV2Pair.s.sol` — Creates a V2 pair via Router/Factory if it does not exist. Required: `PRIVATE_KEY`, `TOKEN0`, `TOKEN1`.

- `script/v2/AddLiquidityAndBurnLP.s.sol` — Adds liquidity to a V2 pair and transfers LP tokens to a burn address. Required: `PRIVATE_KEY`, `TOKEN0`, `TOKEN1`, `AMOUNT0`, `AMOUNT1`.

- `script/v3/CreatePool.s.sol` — Calls Uniswap V3 Factory to create a pool (example uses a hard-coded factory address). Required: `PRIVATE_KEY`.

- `script/v3/InitPool.s.sol` — Calls `initialize` on an already-deployed V3 pool. Required: `PRIVATE_KEY`.

- `script/v3/AddLiquidity.s.sol` — Mints a Uniswap V3 NFT LP via `NonfungiblePositionManager`. Requires approvals and env vars: `PRIVATE_KEY`, `TOKEN0`, `TOKEN1`.

- `script/v3/BurnMintToken.s.sol` — Transfers a V3 NFT LP to the dead address to “burn” it. Required: `PRIVATE_KEY`, `MIN_TOKEN_ID`.

- `script/v4/V4CreatePool.s.sol` — Creates a V4 pool and adds liquidity (initializes pool, computes ticks and liquidity, then uses `multicall`). Depends on `lib/v4-core` and `lib/v4-periphery`. Required: `PRIVATE_KEY`, `TOKEN0`, `TOKEN1`, `AMOUNT0`, `AMOUNT1`, `INIT_PRICE`.

Important notes

- Many scripts include hard-coded contract addresses (Factory, Router, PositionManager). Verify and replace these addresses for the target network before broadcasting transactions.
- Running scripts with `--broadcast` will send real transactions to the specified RPC — only run on networks you control and with keys you trust.

Example `.env`

```env
# Private key
PRIVATE_KEY=0x...

# Token deployment
TOKEN_NAME=MyToken
SYMBOL=MTK
SUPPLY=1000000

# V2/V3/V4 script parameters
TOKEN0=0x...  # e.g. USDT
TOKEN1=0x...  # e.g. WETH
AMOUNT0=1000
AMOUNT1=1
INIT_PRICE=100
MIN_TOKEN_ID=1234
```

Run scripts (examples)

```bash
# Deploy ERC20
forge script script/DeployToken.s.sol:Deploy --rpc-url <RPC_URL> --private-key $PRIVATE_KEY --broadcast

# Create V2 pair
forge script script/v2/CreateV2Pair.s.sol:CreateV2Pair --rpc-url <RPC_URL> --private-key $PRIVATE_KEY --broadcast

# Create and add liquidity on V4
forge script script/v4/V4CreatePool.s.sol:V4CreatePoolAndAddLiquidity --rpc-url <RPC_URL> --private-key $PRIVATE_KEY --broadcast
```

Project configuration

The `foundry.toml` in the repository root already sets `src`, `out`, and `lib`, and includes remappings for local libraries such as `lib/v2-core` and `lib/v2-periphery`. Adjust remappings as needed for your environment.

Contributing

- Add contracts to `src/` and scripts to `script/`.
- Place tests in `test/` and keep them fast and deterministic.

License

Source files include SPDX headers; the project follows MIT licensing where declared.

—

If you want I can:

- produce an English + Chinese bilingual README (both files),
- create a `README_en.md` instead of replacing this file, or
- generate a ` .env.example` file and commit it for convenience.

Tell me which you prefer and I will proceed.
