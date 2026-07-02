#!/bin/bash
set -e

source dev-container-features-test-lib

check "websocat is on PATH" command -v websocat
check "websocat --version exits 0" websocat --version
check "installed version is 1.12.0" bash -c "websocat --version 2>&1 | grep -q '1.12.0'"

reportResults
