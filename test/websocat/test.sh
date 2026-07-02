#!/bin/bash
set -e

source dev-container-features-test-lib

check "websocat is on PATH" command -v websocat
check "websocat --version exits 0" websocat --version

reportResults
