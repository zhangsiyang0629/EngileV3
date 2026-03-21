// script/AddLiquidity.s.sol
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
}

interface INonfungiblePositionManager {
    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    function mint(
        MintParams calldata params
    ) external returns (uint256, uint128, uint256, uint256);

    function burn(uint256 tokenId) external;
}

contract AddLiquidity is Script {
    address constant POSITION_MANAGER =
        0x1238536071E1c677A632429e3655c799b22cDA52;

    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");

        address BTCB = vm.envAddress("TOKEN1");
        address USDTB = vm.envAddress("TOKEN0");

        vm.startBroadcast(pk);

        IERC20(BTCB).approve(POSITION_MANAGER, type(uint256).max);
        IERC20(USDTB).approve(POSITION_MANAGER, type(uint256).max);

        (uint256 tokenId, , , ) = INonfungiblePositionManager(POSITION_MANAGER)
            .mint(
                INonfungiblePositionManager.MintParams({
                    token0: USDTB,
                    token1: BTCB,
                    fee: 3000,
                    tickLower: -887220,
                    tickUpper: 887220,
                    amount0Desired: 10000000 ether,
                    amount1Desired: 100000 ether,
                    amount0Min: 0,
                    amount1Min: 0,
                    recipient: msg.sender,
                    deadline: block.timestamp + 1 hours
                })
            );

        console2.log("LP token", tokenId);
        console2.log("msg.sender", msg.sender);

        vm.stopBroadcast();
    }
}
