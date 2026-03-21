// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../../lib/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "../../lib/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}

contract CreateV2Pair is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);

        address token0 = vm.envAddress("TOKEN0"); // eg. USDTB
        address token1 = vm.envAddress("TOKEN1"); // eg. BTCB
        address routerAddr = 0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3;

        IUniswapV2Router02 router = IUniswapV2Router02(routerAddr);

        // 获取 Factory
        IUniswapV2Factory factory = IUniswapV2Factory(router.factory());

        // 检查是否已有 Pair
        address existingPair = factory.getPair(token0, token1);
        if (existingPair != address(0)) {
            console.log("Pair already exists at:", existingPair);
        } else {
            // 创建交易对
            address pairAddr = factory.createPair(token0, token1);
            console.log("New Pair deployed at:", pairAddr);
        }

        vm.stopBroadcast();
    }
}
