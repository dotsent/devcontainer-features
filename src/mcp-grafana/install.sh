#!/bin/sh

set -eu

feature_dir="$(CDPATH= cd "$(dirname "$0")" && pwd)"
install_dir="${MCP_GRAFANA_INSTALL_DIR:-/usr/local/bin}"
license_dir="${MCP_GRAFANA_LICENSE_DIR:-/usr/local/share/licenses/mcp-grafana}"

if [ "$(uname -s)" != "Linux" ]; then
  echo "mcp-grafana Dev Container Feature supports Linux containers only" >&2
  exit 1
fi

case "$(uname -m)" in
  x86_64 | amd64) asset_name="mcp-grafana-linux-amd64" ;;
  aarch64 | arm64) asset_name="mcp-grafana-linux-arm64" ;;
  *)
    echo "mcp-grafana does not provide a binary for architecture $(uname -m)" >&2
    exit 1
    ;;
esac

command -v sha256sum >/dev/null 2>&1 || {
  echo "mcp-grafana installation requires sha256sum" >&2
  exit 1
}

if [ ! -f "$feature_dir/bin/$asset_name" ] || [ ! -f "$feature_dir/SHA256SUMS" ]; then
  echo "mcp-grafana feature artifact is missing its bundled release assets" >&2
  exit 1
fi

if [ ! -f "$feature_dir/third-party/mcp-grafana-LICENSE" ]; then
  echo "mcp-grafana feature artifact is missing the upstream license" >&2
  exit 1
fi

(
  cd "$feature_dir/bin"
  sha256sum -c "$feature_dir/SHA256SUMS"
)

mkdir -p "$install_dir" "$license_dir"
cp "$feature_dir/bin/$asset_name" "$install_dir/mcp-grafana"
cp "$feature_dir/third-party/mcp-grafana-LICENSE" "$license_dir/LICENSE"
chmod 0755 "$install_dir/mcp-grafana"
chmod 0644 "$license_dir/LICENSE"

"$install_dir/mcp-grafana" --version >/dev/null
