---
name: robinhood-trader
description: >
  ACP CLI skill for trading, swapping, sending, and checking balances on
  Robinhood Chain (4663) and Base (8453) using the acp trade and acp wallet
  commands. Triggers when the user mentions Robinhood Chain, VIRTUAL, PHOOD,
  USDG, swapping tokens, bridging, sending ETH, checking balances on either
  chain, or any acp trade/wallet operation. Also handles ACP agent offerings
  for robinhood_swap, robinhood_send, and robinhood_balance.
---

# Robinhood Trader Skill

A hands-on skill for executing token swaps, ETH sends, and balance checks
on Robinhood Chain (4663) and Base (8453) via the ACP CLI.

## Key Rules

- Always do a --dry-run before executing a trade to confirm the route and
  expected output. Show the preview to the user and ask for confirmation.
- Use contract addresses (not symbols) for non-canonical tokens to avoid
  ambiguity errors. Canonical symbols accepted: eth, usdc, usdg, weth, virtual.
- Robinhood Chain (4663) routes exclusively through LiFi → Relay.
  30% slippage is normal on this chain due to lower liquidity.
- Never sell 100% of a token — keep a small dust amount or the platform
  may reject the transaction.
- Balance updates on Robinhood Chain are slow (can lag 5–10 min). If a tx
  hash is returned with status: success, the trade went through even if
  balance has not updated yet.
- For raw ETH sends use acp wallet send-transaction (not acp trade).
  Convert ETH amount to wei: 0.003 ETH = 3000000000000000 wei.

## Workflow

### 1. Check balance
```bash
acp wallet balance --chain-id 4663   # Robinhood Chain
acp wallet balance --chain-id 8453   # Base
```

### 2. Swap tokens (always dry-run first)
```bash
acp trade --token-in <address_or_symbol> --chain-in <chainId> \
  --amount-in <amount> --token-out <address_or_symbol> --chain-out <chainId> \
  --dry-run

acp trade --token-in <address_or_symbol> --chain-in <chainId> \
  --amount-in <amount> --token-out <address_or_symbol> --chain-out <chainId>
```

### 3. Send ETH
```bash
acp wallet send-transaction --chain-id <chainId> \
  --to <recipient_address> --value <amount_in_wei>
```

### 4. Bridge cross-chain
```bash
acp trade \
  --token-in 0xc6911796042b15d7fa4f6cde69e245ddcd3d9c31 --chain-in 4663 \
  --amount-in <amount> \
  --token-out 0x0b3e328455c4059eeb9e3f84b5543f74e24e7e1b --chain-out 8453
```

## Known Working Pairs on Robinhood Chain

| From | To | Works? |
|------|----|--------|
| VIRTUAL | ETH | Reliable |
| VIRTUAL | USDG | Works |
| PHOOD | VIRTUAL | Works |
| PHOOD | USDG | Routes to VIRTUAL instead |
| VIRTUAL | WETH | WETH not on chain 4663 |

## ACP Marketplace Offerings (airplane agent)

airplane agent ID: 019f0a02-50d4-7169-b047-a5771369e32a
Wallet: 0x3282f5ae930f8be53695de152cf890b9385e8263

| Offering | Price | Description |
|----------|-------|-------------|
| robinhood_swap | $1 USDC | Swap tokens on Robinhood Chain |
| robinhood_send | $1 USDC | Send ETH to a wallet on Robinhood Chain |
| robinhood_balance | $1 USDC | Check balances on Robinhood/Base |

## Script Helper

For automated batch operations, use the bundled script:
```bash
bash scripts/trade.sh swap <fromToken> <amount> <toToken>
bash scripts/trade.sh send <toAddress> <amountEth>
bash scripts/trade.sh balance [robinhood|base]
```

Read references/tokens.md for all known token contract addresses on each chain.
