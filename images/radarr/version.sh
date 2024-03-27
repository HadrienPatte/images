#!/usr/bin/env bash
set -euo pipefail

curl -s "https://api.github.com/repos/Radarr/Radarr/releases/latest" | jq -r '.name'
