#!/usr/bin/env bash
# robinhood-trader skill helper script
# Usage:
#   bash trade.sh swap <fromToken> <amount> <toToken> [chainId]
#   bash trade.sh send <toAddress> <amountEth> [chainId]
#   bash trade.sh balance [robinhood|base|all]

set -euo pipefail

ROBINHOOD_CHAIN=4663
BASE_CHAIN=8453

VIRTUAL_RH="0xc6911796042b15d7fa4f6cde69e245ddcd3d9c31"
PHOOD_RH="0x26c41b10527de2dc870fa5c9d5f4a8dbaa966cdf"
USDG_RH="0x5fc5360d0400a0fd4f2af552add042d716f1d168"
VIRTUAL_BASE="0x0b3e328455c4059eeb9e3f84b5543f74e24e7e1b"
USDC_BASE="0x833589fcd6edb6e08f4c7c32d4f71b54bda02913"

cmd="${1:-help}"

case "$cmd" in
  swap)
    FROM_TOKEN="${2:?Error: fromToken required}"
    AMOUNT="${3:?Error: amount required}"
    TO_TOKEN="${4:?Error: toToken required}"
    CHAIN="${5:-$ROBINHOOD_CHAIN}"

    echo "=== Dry run: $AMOUNT $FROM_TOKEN → $TO_TOKEN on chain $CHAIN ==="
    acp trade \
      --token-in "$FROM_TOKEN" --chain-in "$CHAIN" \
      --amount-in "$AMOUNT" \
      --token-out "$TO_TOKEN" --chain-out "$CHAIN" \
      --dry-run

    echo ""
    read -rp "Execute? (y/N): " confirm
    if [[ "${confirm,,}" == "y" ]]; then
      echo "=== Executing swap ==="
      acp trade \
        --token-in "$FROM_TOKEN" --chain-in "$CHAIN" \
        --amount-in "$AMOUNT" \
        --token-out "$TO_TOKEN" --chain-out "$CHAIN"
    else
      echo "Cancelled."
    fi
    ;;

  send)
    TO_ADDR="${2:?Error: toAddress required}"
    AMOUNT_ETH="${3:?Error: amountEth required}"
    CHAIN="${4:-$ROBINHOOD_CHAIN}"
    AMOUNT_WEI=$(awk "BEGIN {printf \"%.0f\", $AMOUNT_ETH * 1000000000000000000}")

    echo "=== Sending ${AMOUNT_ETH} ETH (${AMOUNT_WEI} wei) to ${TO_ADDR} on chain ${CHAIN} ==="
    read -rp "Confirm send? (y/N): " confirm
    if [[ "${confirm,,}" == "y" ]]; then
      acp wallet send-transaction \
        --chain-id "$CHAIN" \
        --to "$TO_ADDR" \
        --value "$AMOUNT_WEI"
    else
      echo "Cancelled."
    fi
    ;;

  balance)
    CHAIN_NAME="${2:-all}"
    case "$CHAIN_NAME" in
      robinhood|rh|4663)
        echo "=== Robinhood Chain Balance ==="
        acp wallet balance --chain-id $ROBINHOOD_CHAIN
        ;;
      base|8453)
        echo "=== Base Chain Balance ==="
        acp wallet balance --chain-id $BASE_CHAIN
        ;;
      *)
        echo "=== Robinhood Chain Balance ==="
        acp wallet balance --chain-id $ROBINHOOD_CHAIN
        echo ""
        echo "=== Base Chain Balance ==="
        acp wallet balance --chain-id $BASE_CHAIN
        ;;
    esac
    ;;

  help|*)
    echo "Usage:"
    echo "  bash trade.sh swap <fromToken> <amount> <toToken> [chainId]"
    echo "  bash trade.sh send <toAddress> <amountEth> [chainId]"
    echo "  bash trade.sh balance [robinhood|base|all]"
    echo ""
    echo "Token shortcuts (Robinhood Chain):"
    echo "  VIRTUAL: $VIRTUAL_RH"
    echo "  PHOOD:   $PHOOD_RH"
    echo "  USDG:    $USDG_RH"
    echo ""
    echo "Examples:"
    echo "  bash trade.sh swap $VIRTUAL_RH 1 eth"
    echo "  bash trade.sh send 0x2b8b807ff5d3a148ab90aebf4c3368e93ab370f8 0.003"
    echo "  bash trade.sh balance robinhood"
    ;;
esac
