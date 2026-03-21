// script/InitPool.s.sol
pragma solidity ^0.8.20;

import "forge-std/Script.sol";

interface IUniswapV3Pool {
    function initialize(uint160 sqrtPriceX96) external;
}

contract InitPool is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");

        address pool = 0xB0223eA2626d7BEe26aB0F0Fd0aD9417012719c4;

        vm.startBroadcast(pk);

        IUniswapV3Pool(pool).initialize(792281625142643375935439503360);

        vm.stopBroadcast();
    }
}
