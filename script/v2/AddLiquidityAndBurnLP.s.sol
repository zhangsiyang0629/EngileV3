// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../../lib/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}

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

contract AddLiquidity is Script {
    address constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);

        address token0 = vm.envAddress("TOKEN0"); // eg. USDTB
        address token1 = vm.envAddress("TOKEN1"); // eg. BTCB
        address routerAddr = 0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3;

        IUniswapV2Router02 router = IUniswapV2Router02(routerAddr);

        uint256 token0Supply = vm.envUint("AMOUNT0");
        uint256 token1Supply = vm.envUint("AMOUNT1");
        uint256 amount0 = token0Supply * 1 ether;
        uint256 amount1 = token1Supply * 1 ether;

        // 必须先 approve
        IERC20(token0).approve(routerAddr, amount0);
        IERC20(token1).approve(routerAddr, amount1);

        (, , uint liquidity) = router.addLiquidity(
            token0,
            token1,
            amount0,
            amount1,
            0,
            0,
            msg.sender,
            block.timestamp + 3600
        );

        console.log("Liquidity tokens received:", liquidity);
        // 获取 LP token 合约地址
        IUniswapV2Factory factory = IUniswapV2Factory(router.factory());
        address pairAddr = factory.getPair(token0, token1);
        console.log("Pair address (LP token):", pairAddr);
        // 将 LP token 转给 dead address
        IERC20(pairAddr).transfer(DEAD_ADDRESS, liquidity);
        console.log("LP token sent to dead address");

        vm.stopBroadcast();
    }
}
