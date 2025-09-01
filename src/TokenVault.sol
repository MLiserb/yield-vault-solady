// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Ownable} from "solady/src/auth/Ownable.sol";
import {ReentrancyGuard} from "solady/src/utils/ReentrancyGuard.sol";
import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "solady/src/utils/FixedPointMathLib.sol";
import {LibString} from "solady/src/utils/LibString.sol";
import {SSTORE2} from "solady/src/utils/SSTORE2.sol";

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TokenVault is Ownable, ReentrancyGuard {
    using SafeTransferLib for address;
    using FixedPointMathLib for uint256;
    using LibString for uint256;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);

    IERC20 public immutable depositToken;
    IERC20 public immutable rewardToken;
    
    uint256 public yieldRate = 1000; // 10% per year (basis points)
    uint256 public totalDeposits;
    address public metadataPointer;

    struct UserInfo {
        uint256 depositAmount;
        uint256 lastRewardTime;
        uint256 pendingRewards;
    }

    mapping(address => UserInfo) public userInfo;

    modifier updateRewards(address user) {
        UserInfo storage user_ = userInfo[user];
        if (user_.depositAmount > 0 && user_.lastRewardTime > 0) {
            uint256 timeElapsed = block.timestamp - user_.lastRewardTime;
            uint256 reward = (user_.depositAmount * yieldRate * timeElapsed) / (365 days * 10000);
            user_.pendingRewards += reward;
        }
        user_.lastRewardTime = block.timestamp;
        _;
    }

    constructor(
        address _depositToken,
        address _rewardToken,
        string memory _metadata
    ) {
        _initializeOwner(msg.sender);
        depositToken = IERC20(_depositToken);
        rewardToken = IERC20(_rewardToken);
        
        // Store metadata using SSTORE2
        metadataPointer = SSTORE2.write(bytes(_metadata));
    }

    function deposit(uint256 amount) external nonReentrant updateRewards(msg.sender) {
        require(amount > 0, "Amount must be > 0");
        
        UserInfo storage user = userInfo[msg.sender];
        
        address(depositToken).safeTransferFrom(msg.sender, address(this), amount);
        
        user.depositAmount += amount;
        totalDeposits += amount;
        
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) external nonReentrant updateRewards(msg.sender) {
        UserInfo storage user = userInfo[msg.sender];
        require(user.depositAmount >= amount, "Insufficient balance");
        
        user.depositAmount -= amount;
        totalDeposits -= amount;
        
        address(depositToken).safeTransfer(msg.sender, amount);
        
        emit Withdraw(msg.sender, amount);
    }

    function claimRewards() external nonReentrant updateRewards(msg.sender) {
        UserInfo storage user = userInfo[msg.sender];
        uint256 rewards = user.pendingRewards;
        require(rewards > 0, "No rewards available");
        
        user.pendingRewards = 0;
        address(rewardToken).safeTransfer(msg.sender, rewards);
        
        emit RewardClaimed(msg.sender, rewards);
    }

    function pendingRewards(address user) external view returns (uint256) {
        UserInfo memory user_ = userInfo[user];
        if (user_.depositAmount == 0 || user_.lastRewardTime == 0) return user_.pendingRewards;
        
        uint256 timeElapsed = block.timestamp - user_.lastRewardTime;
        uint256 newReward = (user_.depositAmount * yieldRate * timeElapsed) / (365 days * 10000);
        return user_.pendingRewards + newReward;
    }

    function getMetadata() external view returns (string memory) {
        return string(SSTORE2.read(metadataPointer));
    }

    function setYieldRate(uint256 _yieldRate) external onlyOwner {
        require(_yieldRate <= 10000, "Rate too high");
        yieldRate = _yieldRate;
    }
}
