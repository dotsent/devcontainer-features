#!/usr/bin/env bash

set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d)"
requested_feature="${1:-all}"

cleanup() {
  local status=$?
  trap - EXIT
  find "$test_root" -mindepth 1 -delete
  rmdir "$test_root"
  exit "$status"
}
trap cleanup EXIT

case "$requested_feature" in
  all | mcp-grafana | migrate | promtool) ;;
  *)
    echo "unknown feature: $requested_feature" >&2
    exit 1
    ;;
esac

if [[ "$requested_feature" == "all" || "$requested_feature" == "mcp-grafana" ]]; then
  MCP_GRAFANA_INSTALL_DIR="$test_root/bin" \
  MCP_GRAFANA_LICENSE_DIR="$test_root/licenses/mcp-grafana" \
    "$repository_root/src/mcp-grafana/install.sh"
  "$test_root/bin/mcp-grafana" --version | grep -E '^v0\.14\.0([+-]|$)'
  test -f "$test_root/licenses/mcp-grafana/LICENSE"
fi

if [[ "$requested_feature" == "all" || "$requested_feature" == "migrate" ]]; then
  MIGRATE_INSTALL_DIR="$test_root/bin" \
  MIGRATE_LICENSE_DIR="$test_root/licenses/migrate" \
    "$repository_root/src/migrate/install.sh"
  "$test_root/bin/migrate" -version 2>&1 | grep -F '4.18.2'
  test -f "$test_root/licenses/migrate/LICENSE"
fi

if [[ "$requested_feature" == "all" || "$requested_feature" == "promtool" ]]; then
  PROMTOOL_INSTALL_DIR="$test_root/bin" \
  PROMTOOL_LICENSE_DIR="$test_root/licenses/promtool" \
    "$repository_root/src/promtool/install.sh"
  "$test_root/bin/promtool" --version | grep -F 'version 3.12.0'
  "$test_root/bin/promtool" check rules "$repository_root/test/promtool/valid-rules.yaml" |
    grep -F 'SUCCESS: 1 rules found'
  test -f "$test_root/licenses/promtool/LICENSE"
fi
