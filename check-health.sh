#!/usr/bin/env bash

export CHAINWEB_NETWORK=${CHAINWEB_NETWORK:-mainnet01}
export CHAINWEB_P2P_PORT=${CHAINWEB_P2P_PORT:-1789}

CURRENT_NODE_HEIGHT=$(curl -fsLk "https://localhost:$CHAINWEB_P2P_PORT/chainweb/0.0/$CHAINWEB_NETWORK/cut" | jq -r '.height')
if ! egrep -o "^[0-9]+$" <<< "$CURRENT_NODE_HEIGHT" &>/dev/null; then
  echo "Kadena daemon not responding...."
  exit 1
fi

