#!/usr/bin/env bash

set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
work_dir="$(mktemp -d)"
requested_feature="${1:-all}"

cleanup() {
  local status=$?
  trap - EXIT
  find "$work_dir" -mindepth 1 -delete
  rmdir "$work_dir"
  exit "$status"
}
trap cleanup EXIT

case "$requested_feature" in
  all | mcp-grafana | migrate | promtool | websocat) ;;
  *)
    echo "unknown feature: $requested_feature" >&2
    exit 1
    ;;
esac

prepare_mcp_grafana_asset() {
  local upstream_arch="$1"
  local output_name="$2"
  local expected_sha256="$3"
  local feature_dir="$repository_root/src/mcp-grafana"
  local upstream_version="0.14.0"
  local archive_name="mcp-grafana_Linux_${upstream_arch}.tar.gz"
  local archive_path="$work_dir/$archive_name"
  local extract_dir="$work_dir/mcp-grafana-$upstream_arch"

  mkdir -p "$feature_dir/bin" "$feature_dir/third-party" "$extract_dir"
  curl --fail --silent --show-error --location \
    "https://github.com/grafana/mcp-grafana/releases/download/v$upstream_version/$archive_name" \
    --output "$archive_path"
  echo "$expected_sha256  $archive_path" | sha256sum --check -
  tar -xzf "$archive_path" -C "$extract_dir" mcp-grafana LICENSE
  cp "$extract_dir/mcp-grafana" "$feature_dir/bin/$output_name"
  chmod 0755 "$feature_dir/bin/$output_name"

  if [[ ! -f "$feature_dir/third-party/mcp-grafana-LICENSE" ]]; then
    cp "$extract_dir/LICENSE" "$feature_dir/third-party/mcp-grafana-LICENSE"
  elif ! cmp -s "$extract_dir/LICENSE" "$feature_dir/third-party/mcp-grafana-LICENSE"; then
    echo "mcp-grafana release archives contain different license files" >&2
    exit 1
  fi
}

prepare_mcp_grafana() {
  local feature_dir="$repository_root/src/mcp-grafana"
  prepare_mcp_grafana_asset x86_64 mcp-grafana-linux-amd64 \
    81c5ab1c44a2e7cd270420b2c23587beb62ab5982f2dde8b800405aa9ec6e82c
  prepare_mcp_grafana_asset arm64 mcp-grafana-linux-arm64 \
    06935a5fe8003a4fe5885ba76efa74329df22685e85187e6d101cf6d99a15709
  (
    cd "$feature_dir/bin"
    sha256sum mcp-grafana-linux-amd64 mcp-grafana-linux-arm64 >"$feature_dir/SHA256SUMS"
  )
}

prepare_promtool_asset() {
  local upstream_arch="$1"
  local output_name="$2"
  local expected_sha256="$3"
  local feature_dir="$repository_root/src/promtool"
  local upstream_version="3.12.0"
  local archive_root="prometheus-${upstream_version}.linux-${upstream_arch}"
  local archive_name="$archive_root.tar.gz"
  local archive_path="$work_dir/$archive_name"
  local extract_dir="$work_dir/promtool-$upstream_arch"

  mkdir -p "$feature_dir/bin" "$feature_dir/third-party" "$extract_dir"
  curl --fail --silent --show-error --location \
    "https://github.com/prometheus/prometheus/releases/download/v$upstream_version/$archive_name" \
    --output "$archive_path"
  echo "$expected_sha256  $archive_path" | sha256sum --check -
  tar -xzf "$archive_path" -C "$extract_dir" "$archive_root/promtool" "$archive_root/LICENSE"
  cp "$extract_dir/$archive_root/promtool" "$feature_dir/bin/$output_name"
  chmod 0755 "$feature_dir/bin/$output_name"

  if [[ ! -f "$feature_dir/third-party/prometheus-LICENSE" ]]; then
    cp "$extract_dir/$archive_root/LICENSE" "$feature_dir/third-party/prometheus-LICENSE"
  elif ! cmp -s "$extract_dir/$archive_root/LICENSE" "$feature_dir/third-party/prometheus-LICENSE"; then
    echo "Prometheus release archives contain different license files" >&2
    exit 1
  fi
}

prepare_promtool() {
  local feature_dir="$repository_root/src/promtool"
  prepare_promtool_asset amd64 promtool-linux-amd64 \
    20da47f8e5303f74aecb78edd7f7e39041dac08ac4939dba75efd7a900ae8867
  prepare_promtool_asset arm64 promtool-linux-arm64 \
    281492bf04ed171cb09d24377e9777f56e55ccb6445ef197b66bd1693bd9b7f1
  (
    cd "$feature_dir/bin"
    sha256sum promtool-linux-amd64 promtool-linux-arm64 >"$feature_dir/SHA256SUMS"
  )
}

prepare_migrate_asset() {
  local upstream_arch="$1"
  local output_name="$2"
  local expected_sha256="$3"
  local feature_dir="$repository_root/src/migrate"
  local upstream_version="4.18.2"
  local archive_name="migrate.linux-${upstream_arch}.tar.gz"
  local archive_path="$work_dir/$archive_name"
  local extract_dir="$work_dir/migrate-$upstream_arch"

  mkdir -p "$feature_dir/bin" "$feature_dir/third-party" "$extract_dir"
  curl --fail --silent --show-error --location \
    "https://github.com/golang-migrate/migrate/releases/download/v$upstream_version/$archive_name" \
    --output "$archive_path"
  echo "$expected_sha256  $archive_path" | sha256sum --check -
  tar -xzf "$archive_path" -C "$extract_dir" migrate LICENSE
  cp "$extract_dir/migrate" "$feature_dir/bin/$output_name"
  chmod 0755 "$feature_dir/bin/$output_name"

  if [[ ! -f "$feature_dir/third-party/migrate-LICENSE" ]]; then
    cp "$extract_dir/LICENSE" "$feature_dir/third-party/migrate-LICENSE"
  elif ! cmp -s "$extract_dir/LICENSE" "$feature_dir/third-party/migrate-LICENSE"; then
    echo "migrate release archives contain different license files" >&2
    exit 1
  fi
}

prepare_migrate() {
  local feature_dir="$repository_root/src/migrate"
  prepare_migrate_asset amd64 migrate-linux-amd64 \
    b8048fed777035609c1a3cd53d864a040d1ca1c6c7b95735e90af83088b28909
  prepare_migrate_asset arm64 migrate-linux-arm64 \
    acb12655bb7472ee9061bac0b5c6cf14b7448ad089b96793b91d485e88f2a713
  (
    cd "$feature_dir/bin"
    sha256sum migrate-linux-amd64 migrate-linux-arm64 >"$feature_dir/SHA256SUMS"
  )
}

if [[ "$requested_feature" == "all" || "$requested_feature" == "mcp-grafana" ]]; then
  prepare_mcp_grafana
fi
if [[ "$requested_feature" == "all" || "$requested_feature" == "migrate" ]]; then
  prepare_migrate
fi
if [[ "$requested_feature" == "all" || "$requested_feature" == "promtool" ]]; then
  prepare_promtool
fi
