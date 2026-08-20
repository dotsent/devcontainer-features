# Grafana MCP Dev Container Feature

Installs the official [`grafana/mcp-grafana`](https://github.com/grafana/mcp-grafana)
binary into `/usr/local/bin`.

The Feature bundles static Linux binaries for `amd64` and `arm64`, so the
target devcontainer does not need Go, Python, `uv`, Docker, or access to GitHub
Releases during its build.

```json
{
  "features": {
    "ghcr.io/dotsent/devcontainer-features/mcp-grafana:1": {}
  }
}
```

Configure credentials in the MCP client's runtime environment, never in
`devcontainer.json`, Feature options, or image build arguments.

```toml
[mcp_servers.grafana]
command = "mcp-grafana"
args = ["-t", "stdio", "--disable-write"]
env_vars = ["GRAFANA_URL", "GRAFANA_SERVICE_ACCOUNT_TOKEN"]
```

This Feature installs `mcp-grafana` v0.14.0.
