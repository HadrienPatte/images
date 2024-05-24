#!/usr/bin/env bash
set -euo pipefail

curl -s "https://api.github.com/repos/jellyfin/jellyfin/releases/latest" | jq -r '.tag_name'
