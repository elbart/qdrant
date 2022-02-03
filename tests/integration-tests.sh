#!/bin/bash
# This runs all integration test in isolation

set -ex

# Ensure current path is project root
cd "$(dirname "$0")/../"

QDRANT_HOST='localhost:6333'

# Build
$(cargo build --features grpc)
# Run in background
$(./target/debug/qdrant) &

## Capture PID of the run
PID=$(pidof "./target/debug/qdrant")
echo $PID

until $(curl --output /dev/null --silent --get --fail http://$QDRANT_HOST/collections); do
  printf 'waiting for server to start...'
  sleep 5
done

echo "server ready to serve traffic"

./tests/basic_api_test.sh

./tests/basic_grpc_test.sh

echo "server is going down"
$(kill -9 $PID)
echo "END"
