#!/bin/bash

# exit when any command fails
set -e

NETWORK_NAME="goerli"

echo "truffle migrate --network $NETWORK_NAME"
truffle migrate --network $NETWORK_NAME