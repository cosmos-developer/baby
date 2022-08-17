#!/usr/bin/env bash
set -eo pipefail

echo "Generating gogo proto code"
cd proto
buf mod update
cd ..
buf generate

# move proto files to the right places
cp -r ./github.com/cosmos-developer/baby/x/* x/
rm -rf ./github.com

go mod tidy -compat=1.18