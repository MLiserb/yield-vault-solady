# Yield Vault - Gas-Optimized DeFi on Monad

A gas-optimized yield farming vault built with [Solady](https://github.com/Vectorized/solady) and deployed on Monad testnet.

## Features

- **Gas-Optimized**: Uses Solady's hyper-efficient implementations
- **Secure**: ReentrancyGuard, SafeTransferLib, and Ownable access control
- **Yield Farming**: 10% APY rewards for depositors
- **Efficient Storage**: SSTORE2 for metadata storage
- **High Performance**: Deployed on Monad's 10k TPS blockchain

## Solady Components Used

- `ERC20` - Gas-optimized token implementation
- `Ownable` - Access control
- `ReentrancyGuard` - Security protection
- `SafeTransferLib` - Safe token transfers
- `SSTORE2` - Efficient storage
- `LibString` - String utilities

## Quick Start

```bash
# Clone and setup
git clone git@github.com:MLiserb/yield-vault.git
cd yield-vault
forge install

# Test
forge test

# Deploy to Monad testnet
source .env
forge script script/Deploy.s.sol --rpc-url https://testnet-rpc.monad.xyz --broadcast
```

## Architecture

### RewardToken.sol
Gas-optimized ERC20 using Solady's implementation.

### TokenVault.sol
Main vault contract featuring:
- Deposit/withdraw functionality
- Automatic yield calculation
- Reward claiming
- Metadata storage via SSTORE2

## Network Configuration

**Monad Testnet:**
- Chain ID: 10143
- RPC: https://testnet-rpc.monad.xyz
- Explorer: https://testnet.monadexplorer.com
- Currency: MON

## Gas Efficiency

Thanks to Solady optimizations:
- Deployment: ~2.4M gas
- Deposits: ~123k gas
- Withdrawals: ~132k gas
- Reward claims: ~45k gas

## Live Deployment

**Deployed on Monad Testnet:**

### Contracts
- **RewardToken:** [`0xd71bCB7C4e7F43A9Da60D73471dd24057A1a38C6`](https://testnet.monadexplorer.com/address/0xd71bCB7C4e7F43A9Da60D73471dd24057A1a38C6)
- **TokenVault:** [`0xc95479eef57C67B2DB7a50f4D73115DbabF81182`](https://testnet.monadexplorer.com/address/0xc95479eef57C67B2DB7a50f4D73115DbabF81182)

### Deployment Command
```bash
forge script script/Deploy.s.sol --rpc-url https://testnet-rpc.monad.xyz --broadcast
```

### Verification Commands
```bash
# Verify RewardToken
forge verify-contract 0xd71bCB7C4e7F43A9Da60D73471dd24057A1a38C6 src/RewardToken.sol:RewardToken \
  --chain 10143 \
  --verifier sourcify \
  --verifier-url https://sourcify-api-monad.blockvision.org

# Verify TokenVault  
forge verify-contract 0xc95479eef57C67B2DB7a50f4D73115DbabF81182 src/TokenVault.sol:TokenVault \
  --chain 10143 \
  --verifier sourcify \
  --verifier-url https://sourcify-api-monad.blockvision.org
```

Both contracts are **verified** and live on Monad testnet! ✅

## License

MIT
