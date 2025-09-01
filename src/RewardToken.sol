// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC20} from "solady/src/tokens/ERC20.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";

contract RewardToken is ERC20, Ownable {
    constructor() {
        _initializeOwner(msg.sender);
    }

    function name() public pure override returns (string memory) {
        return "Yield Vault Token";
    }

    function symbol() public pure override returns (string memory) {
        return "YVT";
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
