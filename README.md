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
