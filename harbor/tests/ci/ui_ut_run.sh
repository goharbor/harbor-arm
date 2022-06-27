#!/bin/bash
set -x
set -e

cd ./src/portal
npm install -q --no-progress
npm run test && cd -