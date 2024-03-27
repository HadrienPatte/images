#!/usr/bin/env bash
set -euo pipefail

curl -s "https://api.github.com/repos/Prowlarr/Prowlarr/releases/latest" | jq -r '.name'
