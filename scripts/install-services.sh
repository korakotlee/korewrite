#!/usr/bin/env bash
set -euo pipefail

# KoRewrite - Native macOS Services and Quick Actions Installer
# Installs context menu workflows to ~/Library/Services/ and refreshes pbs

SERVICES_DIR="$HOME/Library/Services"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "==> KoRewrite macOS Services Installer"
mkdir -p "$SERVICES_DIR"

# Build korewrite CLI if not already compiled
if ! command -v korewrite >/dev/null 2>&1; then
    echo "==> Building korewrite executable via Swift PM..."
    (cd "$PROJECT_ROOT" && swift build -c release)
    RELEASE_BIN="$PROJECT_ROOT/.build/release/korewrite"
    if [ -f "$RELEASE_BIN" ]; then
        echo "==> Found compiled binary at $RELEASE_BIN"
        # Offer or copy to ~/.local/bin or /usr/local/bin if directory exists and writable
        if [ -d "$HOME/.local/bin" ]; then
            cp "$RELEASE_BIN" "$HOME/.local/bin/korewrite"
            echo "==> Installed korewrite to $HOME/.local/bin/korewrite"
        fi
    fi
fi

# Run korewrite install-services subcommand
if command -v korewrite >/dev/null 2>&1; then
    korewrite --install-services
elif [ -f "$PROJECT_ROOT/.build/release/korewrite" ]; then
    "$PROJECT_ROOT/.build/release/korewrite" --install-services
elif [ -f "$PROJECT_ROOT/.build/debug/korewrite" ]; then
    "$PROJECT_ROOT/.build/debug/korewrite" --install-services
else
    swift run --package-path "$PROJECT_ROOT" korewrite --install-services
fi

echo "==> Refreshing macOS Services cache (pbs)..."
/System/Library/CoreServices/pbs -flush 2>/dev/null || true

echo "==> Successfully installed KoRewrite Quick Actions in ~/Library/Services/!"
echo "    Available in Right-Click > Services / Quick Actions menu across macOS apps."
