#!/bin/bash
set -e

source dev-container-features-test-lib

check "mcp-grafana is on PATH" command -v mcp-grafana
check "mcp-grafana version is v0.14.0" bash -c "mcp-grafana --version | grep -E '^v0\\.14\\.0([+-]|$)'"
check "mcp-grafana supports read-only mode" bash -c "mcp-grafana --help 2>&1 | grep -F -- '-disable-write'"
check "mcp-grafana license is installed" test -f /usr/local/share/licenses/mcp-grafana/LICENSE

reportResults
