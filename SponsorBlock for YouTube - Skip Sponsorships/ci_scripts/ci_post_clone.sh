#!/bin/sh

set -eu

# Xcode Cloud 从 ci_scripts 目录执行脚本，这里先定位到仓库根目录。
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"
git submodule update --init --recursive

if ! command -v node >/dev/null 2>&1; then
    brew install node
    export PATH="$(brew --prefix node)/bin:$PATH"
fi

cd "$REPO_ROOT/SponsorBlock"

if [ ! -f config.json ]; then
    cp config.json.example config.json
fi

npm ci
npm run build:safari
