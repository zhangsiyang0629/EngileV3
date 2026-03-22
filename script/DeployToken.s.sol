// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/MyToken.sol";

contract Deploy is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        string memory tokenName = vm.envString("TOKEN_NAME");
        string memory symbol = vm.envString("SYMBOL");
        uint256 supply = vm.envUint("SUPPLY");
        uint256 supplyWithDecimals = supply * 1 ether;
        vm.startBroadcast(pk);

        MyToken token = new MyToken(tokenName, symbol, supplyWithDecimals);
        vm.stopBroadcast();
    }
}
