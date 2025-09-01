// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "forge-std/Script.sol";
import "../src/TokenVault.sol";
import "../src/RewardToken.sol";

contract DeployScript is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        console.log("Deploying to Monad Testnet...");
        console.log("Deployer:", vm.addr(deployerPrivateKey));

        // Deploy reward token
        RewardToken rewardToken = new RewardToken();
        console.log("RewardToken:", address(rewardToken));

        // Deploy vault with reward token as both deposit and reward
        TokenVault vault = new TokenVault(
            address(rewardToken), // deposit token
            address(rewardToken), // reward token
            "Gas-optimized yield vault on Monad"
        );

        console.log("TokenVault:", address(vault));

        // Mint tokens to vault for rewards
        rewardToken.mint(address(vault), 1000000e18);
        console.log("Minted 1M tokens to vault for rewards");

        console.log("Explorer: https://testnet.monadexplorer.com");

        vm.stopBroadcast();
    }
}
