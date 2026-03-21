// script/SendLPToDead.s.sol
pragma solidity ^0.8.20;

import "forge-std/Script.sol";

interface IERC721 {
    function transferFrom(address from, address to, uint256 tokenId) external;
}

contract SendLPToDead is Script {
    // 你的 Uniswap V3 NonfungiblePositionManager 地址
    address constant POSITION_MANAGER =
        0x1238536071E1c677A632429e3655c799b22cDA52;

    // 黑洞地址，用于“销毁”NFT
    address constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    function run() external {
        // 从环境变量读取私钥
        uint256 pk = vm.envUint("PRIVATE_KEY");
        // 从环境变量读取你要销毁的 tokenId
        uint256 tokenId = vm.envUint("MIN_TOKEN_ID");

        // 计算对应钱包地址
        address sender = vm.addr(pk);

        // 开始广播交易
        vm.startBroadcast(pk);

        // 将 NFT 转到黑洞地址
        IERC721(POSITION_MANAGER).transferFrom(sender, DEAD_ADDRESS, tokenId);

        vm.stopBroadcast();
    }
}
