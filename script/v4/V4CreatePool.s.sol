// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {PoolKey} from "../../lib/v4-core/src/types/PoolKey.sol";
import {Currency} from "../../lib/v4-core/src/types/Currency.sol";
import {
    IPermit2
} from "../../lib/v4-periphery/lib/permit2/src/interfaces/IPermit2.sol";
import {IPoolManager} from "../../lib/v4-core/src/interfaces/IPoolManager.sol";
import {
    IPositionManager
} from "../../lib/v4-periphery/src/interfaces/IPositionManager.sol";
import {Actions} from "../../lib/v4-periphery/src/libraries/Actions.sol";
import {IHooks} from "../../lib/v4-core/src/interfaces/IHooks.sol";

// 引入官方 V4 辅助库接口
import "../../lib/v4-core/src/libraries/TickMath.sol";
import "../../lib/v4-core/test/utils/LiquidityAmounts.sol";

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}

contract V4CreatePoolAndAddLiquidity is Script {
    IPermit2 permit2;
    IPositionManager positionManager;

    IERC20 internal token0 = IERC20(vm.envAddress("TOKEN0")); // 基础货币，例如eth
    IERC20 internal token1 = IERC20(vm.envAddress("TOKEN1")); // 计价货币，例如usdt
    uint256 amount0 = vm.envUint("AMOUNT0");
    uint256 amount1 = vm.envUint("AMOUNT1");
    uint256 token0Amount;
    uint256 token1Amount;
    Currency currency0;
    Currency currency1;
    IHooks constant hookContract = IHooks(address(0));
    uint256 initPrice = vm.envUint("INIT_PRICE"); // 实际价格，例如 100
    uint24 lpFee = 3000; // 0.3%
    int24 tickSpacing = 30; // 根据 fee 设置的官方 tick spacing
    int24 tickLower;
    int24 tickUpper;
    uint160 startingPrice;

    function run() external {
        // 从 .env 读取私钥和参数
        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);
        (currency0, currency1) = getCurrencies();
        (token0Amount, token1Amount) = getAmounts();

        positionManager = IPositionManager(
            0x429ba70129df741B2Ca2a85BC3A2a3328e5c09b4 // Sepolia PositionManager
        );

        permit2 = permit2 = IPermit2(
            0x000000000022D473030F116dDEE9F6B43aC78BA3
        );

        bytes memory hookData = new bytes(0);

        // 初始化池子
        PoolKey memory poolKey = PoolKey({
            currency0: currency0,
            currency1: currency1,
            fee: lpFee,
            tickSpacing: tickSpacing,
            hooks: hookContract
        });

        // 将实际价格转换为 sqrtPriceX96
        startingPrice = getSqrtPriceX96FromHumanPrice(initPrice);
        console.log("startingPrice", startingPrice);

        // 计算当前 tick
        int24 currentTick = TickMath.getTickAtSqrtPrice(startingPrice);
        console.log("currentTick", currentTick);

        // 设置流动性范围
        tickLower = truncateTickSpacing(
            currentTick - 500 * tickSpacing,
            tickSpacing
        );
        tickUpper = truncateTickSpacing(
            currentTick + 500 * tickSpacing,
            tickSpacing
        );

        console.log("token0", Currency.unwrap(currency0));
        console.log("token1", Currency.unwrap(currency1));
        console.log("tickLower", tickLower);
        console.log("tickUpper", tickUpper);
        console.log("startingPrice", startingPrice);
        console.log("lowerPrice", TickMath.getSqrtPriceAtTick(tickLower));
        console.log("upperPrice", TickMath.getSqrtPriceAtTick(tickUpper));
        console.log("token0Amount", token0Amount);
        console.log("token1Amount", token1Amount);

        // 精确计算 liquidity
        uint128 liquidity = LiquidityAmounts.getLiquidityForAmounts(
            startingPrice,
            TickMath.getSqrtPriceAtTick(tickLower),
            TickMath.getSqrtPriceAtTick(tickUpper),
            token0Amount,
            token1Amount
        );
        console.log("liquidity", liquidity);

        // slippage 容忍
        uint256 amount0Max = token0Amount + 1;
        uint256 amount1Max = token1Amount + 1;

        // 构建 mint 参数
        (
            bytes memory actions,
            bytes[] memory mintParams
        ) = _mintLiquidityParams(
                poolKey,
                tickLower,
                tickUpper,
                liquidity,
                amount0Max,
                amount1Max,
                msg.sender,
                hookData
            );

        // multicall 原子操作：初始化池子 + 添加流动性
        bytes[] memory params = new bytes[](2);

        params[0] = abi.encodeWithSelector(
            positionManager.initializePool.selector,
            poolKey,
            startingPrice,
            hookData
        );

        // 添加流动性
        params[1] = abi.encodeWithSelector(
            positionManager.modifyLiquidities.selector,
            abi.encode(actions, mintParams),
            block.timestamp + 3600
        );

        // approve token
        tokenApprovals();

        // 如果是 ETH pair，valueToPass = token0Amount
        uint256 valueToPass = 0;

        // 执行 multicall
        positionManager.multicall{value: valueToPass}(params);

        console.log("Pool created and liquidity added successfully!");

        vm.stopBroadcast();
    }

    // ---------- 辅助函数 ----------
    function encodePriceSqrt(
        uint256 reserve1,
        uint256 reserve0
    ) internal pure returns (uint160) {
        return uint160((sqrt((reserve1 * 2 ** 192) / reserve0)));
    }

    function getSqrtPriceX96FromHumanPrice(
        uint256 priceAperB
    ) internal view returns (uint160 sqrtPriceX96) {
        require(address(token0) != address(token1));
        uint160 price;
        if (token0 < token1) {
            price = encodePriceSqrt(priceAperB, 1);
        } else {
            price = encodePriceSqrt(1, priceAperB);
        }
        console.log("price", price);
        return price;
    }

    function getSqrtPriceX96(uint256 price) internal pure returns (uint160) {
        // price 是实际价格，例如 100
        uint256 sqrtPrice = sqrt(price * 1e18);
        return uint160(sqrtPrice << 48); // 左移48位 ≈ * 2^96
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function truncateTickSpacing(
        int24 tick,
        int24 tickSpacing1
    ) internal pure returns (int24) {
        return tick - (tick % tickSpacing1);
    }

    function _mintLiquidityParams(
        PoolKey memory poolKey,
        int24 _tickLower,
        int24 _tickUpper,
        uint256 liquidity,
        uint256 amount0Max,
        uint256 amount1Max,
        address recipient,
        bytes memory hookData
    ) internal pure returns (bytes memory, bytes[] memory) {
        bytes memory actions = abi.encodePacked(
            uint8(Actions.MINT_POSITION),
            uint8(Actions.SETTLE_PAIR),
            uint8(Actions.SWEEP),
            uint8(Actions.SWEEP)
        );

        bytes[] memory params = new bytes[](4);
        params[0] = abi.encode(
            poolKey,
            _tickLower,
            _tickUpper,
            liquidity,
            amount0Max,
            amount1Max,
            recipient,
            hookData
        );
        params[1] = abi.encode(poolKey.currency0, poolKey.currency1);
        params[2] = abi.encode(poolKey.currency0, recipient);
        params[3] = abi.encode(poolKey.currency1, recipient);

        return (actions, params);
    }

    function getCurrencies() internal view returns (Currency, Currency) {
        require(address(token0) != address(token1));

        if (token0 < token1) {
            return (
                Currency.wrap(address(token0)),
                Currency.wrap(address(token1))
            );
        } else {
            return (
                Currency.wrap(address(token1)),
                Currency.wrap(address(token0))
            );
        }
    }

    function getAmounts() internal view returns (uint256, uint256) {
        require(address(token0) != address(token1));

        if (token0 < token1) {
            return (amount0 * 1 ether, amount1 * 1 ether);
        } else {
            return (amount1 * 1 ether, amount0 * 1 ether);
        }
    }

    function tokenApprovals() public {
        if (!currency0.isAddressZero()) {
            token0.approve(address(permit2), type(uint256).max);
            permit2.approve(
                address(token0),
                address(positionManager),
                type(uint160).max,
                type(uint48).max
            );
        }

        if (!currency1.isAddressZero()) {
            token1.approve(address(permit2), type(uint256).max);
            permit2.approve(
                address(token1),
                address(positionManager),
                type(uint160).max,
                type(uint48).max
            );
        }
    }
}
