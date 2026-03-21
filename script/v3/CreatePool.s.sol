// script/CreatePool.s.sol
pragma solidity ^0.8.20;

import "forge-std/Script.sol";

interface IUniswapV3Factory {
    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);
}

contract CreatePool is Script {
    address constant FACTORY = 0x0227628f3F023bb0B980b67D528571c95c6DaC1c;

    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");

        address BTCB = 0x5fCBb6193b5dD9771f78e36b6811f3A05FBc684B;
        address USDTB = 0x02b3d7aAd00aEFDB8f3fe1d5E3fdB7ed78CC41A3;

        vm.startBroadcast(pk);

        address pool = IUniswapV3Factory(FACTORY).createPool(BTCB, USDTB, 3000);

        vm.stopBroadcast();
    }
}
