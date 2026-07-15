# robinhood-trader-skill

An ACP CLI skill for trading tokens on **Robinhood Chain (4663)** and **Base (8453)** via the [ACP CLI](https://github.com/Virtual-Protocol/acp-cli).

## What It Does

- **Swap** tokens on Robinhood Chain (VIRTUAL → ETH, VIRTUAL → USDG, PHOOD → VIRTUAL, etc.)
- **Send** ETH to any wallet on Robinhood Chain
- **Check balances** on Robinhood Chain and Base
- **Bridge** tokens cross-chain (Robinhood ↔ Base)

## Prerequisites

- [ACP CLI](https://github.com/Virtual-Protocol/acp-cli) installed and configured
  ```bash
  npm install -g @virtuals-protocol/acp-cli
  acp configure
  acp agent use --agent-id <your-agent-id>
  ```

## Installation

Clone into your `.agents/skills/` directory:

```bash
# Project-level (recommended)
git clone https://github.com/airplanestar888/robinhood-trader-skill \
  .agents/skills/robinhood-trader

# Or user-level (available in all projects)
git clone https://github.com/airplanestar888/robinhood-trader-skill \
  ~/.agents/skills/robinhood-trader
```

## Usage

### Via script
```bash
cd .agents/skills/robinhood-trader

# Check balances
bash scripts/trade.sh balance robinhood
bash scripts/trade.sh balance base
bash scripts/trade.sh balance all

# Swap tokens (dry-run → confirm → execute)
bash scripts/trade.sh swap 0xc6911796042b15d7fa4f6cde69e245ddcd3d9c31 1 eth
bash scripts/trade.sh swap 0xc6911796042b15d7fa4f6cde69e245ddcd3d9c31 10 0x5fc5360d0400a0fd4f2af552add042d716f1d168

# Send ETH
bash scripts/trade.sh send 0x2b8b807ff5d3a148ab90aebf4c3368e93ab370f8 0.003
```

### Via ACP CLI directly
```bash
# Check balance
acp wallet balance --chain-id 4663

# Swap (always dry-run first)
acp trade --token-in 0xc6911796042b15d7fa4f6cde69e245ddcd3d9c31 --chain-in 4663 \
  --amount-in 1 --token-out eth --chain-out 4663 --dry-run

# Send ETH
acp wallet send-transaction --chain-id 4663 \
  --to <address> --value <amount_in_wei>
```

## Known Working Pairs (Robinhood Chain)

| From | To | Status |
|------|----|--------|
| VIRTUAL | ETH | ✅ Reliable |
| VIRTUAL | USDG | ✅ Works |
| PHOOD | VIRTUAL | ✅ Works |
| PHOOD | USDG | ⚠️ Routes to VIRTUAL instead |
| VIRTUAL | WETH | ❌ WETH not on Robinhood Chain |

## Token Addresses

See [`references/tokens.md`](references/tokens.md) for all known contract addresses on Robinhood Chain and Base.

## ACP Marketplace Offerings

This skill powers the **airplane** agent on the ACP marketplace with 3 offerings at **$1 USDC** each:

| Offering | Description |
|----------|-------------|
| `robinhood_swap` | Swap tokens on Robinhood Chain via LiFi/Relay |
| `robinhood_send` | Send ETH to any wallet on Robinhood Chain |
| `robinhood_balance` | Check balances on Robinhood Chain or Base |

## Route Info

All swaps on Robinhood Chain route through **LiFi → Relay** protocol. Expect:
- 30% slippage tolerance (normal for newer chain)
- Balance updates may lag 5–10 minutes after tx confirmation
- `status: success` + tx hash = trade executed, even if balance hasn't updated yet

## License

MIT
