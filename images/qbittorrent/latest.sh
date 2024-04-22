#!/usr/bin/env bash
set -euo pipefail

curl -s "https://api.github.com/repos/userdocs/qbittorrent-nox-static/releases/latest" | jq -r '.tag_name'
