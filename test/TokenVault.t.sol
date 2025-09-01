// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import "../src/TokenVault.sol";
import "../src/RewardToken.sol";

contract TokenVaultTest is Test {
    TokenVault vault;
    RewardToken token;
    
    address user1 = address(0x1);

    function setUp() public {
        token = new RewardToken();
        vault = new TokenVault(
            address(token),
            address(token),
            "Test vault"
        );
        
        // Setup tokens
        token.mint(user1, 1000e18);
        token.mint(address(vault), 10000e18);
        
        vm.prank(user1);
        token.approve(address(vault), type(uint256).max);
    }

    function testDeposit() public {
        vm.prank(user1);
        vault.deposit(100e18);
        
        (uint256 amount,,) = vault.userInfo(user1);
        assertEq(amount, 100e18);
        assertEq(vault.totalDeposits(), 100e18);
    }

    function testWithdraw() public {
        vm.prank(user1);
        vault.deposit(100e18);
        
        vm.prank(user1);
        vault.withdraw(50e18);
        
        (uint256 amount,,) = vault.userInfo(user1);
        assertEq(amount, 50e18);
    }

    function testRewards() public {
        vm.prank(user1);
        vault.deposit(100e18);
        
        // Check initial state
        (,uint256 lastTime,) = vault.userInfo(user1);
        console.log("Last reward time after deposit:", lastTime);
        console.log("Current timestamp:", block.timestamp);
        
        // Fast forward 1 year
        vm.warp(block.timestamp + 365 days);
        console.log("New timestamp:", block.timestamp);
        
        uint256 pending = vault.pendingRewards(user1);
        console.log("Pending rewards:", pending);
        assertGt(pending, 0);
    }

    function testMetadata() public {
        string memory metadata = vault.getMetadata();
        assertEq(metadata, "Test vault");
    }
}
