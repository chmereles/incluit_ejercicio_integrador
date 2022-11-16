#!/bin/bash

# exit when any command fails
set -e

$NETWORK_NAME = "testing"

echo "----------------------------COMPILE---------------------------------"
echo "truflle complile --network $NETWORK_NAME"
truflle complile --network $NETWORK_NAME

echo "truflle migrate --network $NETWORK_NAME"
truflle migrate --network $NETWORK_NAME

echo "truflle test --network $NETWORK_NAME"
truflle test --network $NETWORK_NAME