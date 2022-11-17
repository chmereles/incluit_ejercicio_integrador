#!/bin/bash

# exit when any command fails
set -e

NETWORK_NAME="ganache"

echo "----------------------------COMPILE---------------------------------"
echo "truffle complile --network $NETWORK_NAME"
truffle complile --network $NETWORK_NAME

echo "----------------------------TEST---------------------------------"
echo "truffle test --network $NETWORK_NAME"
truffle test 

echo "----------------------------MIGRATE---------------------------------"
echo "truffle migrate --network $NETWORK_NAME"
truffle migrate --network $NETWORK_NAME