#!/usr/bin/env bash
# MindBehindIT MCP Proxy – macOS one-line installer
# Run: curl -fsSL https://Tim-Ganther.github.io/mcp-telekom-proxy-download/install.sh | bash
# Or:  curl -fsSL https://Tim-Ganther.github.io/mcp-telekom-proxy-download/install.sh -o install.sh && bash install.sh

set -e
BASE_URL="${BASE_URL:-https://Tim-Ganther.github.io/mcp-telekom-proxy-download}"
ZIP_URL="${BASE_URL}/MindBehindIT-MCP-Proxy.zip"
APP_NAME="MindBehindIT MCP Proxy.app"
DMG_NAME="MindBehindIT-MCP-Proxy.dmg"

echo ""
echo "  ╔══════════════════════════════════════════════════════════════╗"
echo "  ║                                                              ║"
echo "  ║        ███╗   ███╗██████╗ ██╗████████╗                      ║"
echo "  ║        ████╗ ████║██╔══██╗██║╚══██╔══╝                      ║"
echo "  ║        ██╔████╔██║██████╔╝██║   ██║                         ║"
echo "  ║        ██║╚██╔╝██║██╔══██╗██║   ██║                         ║"
echo "  ║        ██║ ╚═╝ ██║██████╔╝██║   ██║                         ║"
echo "  ║        ╚═╝     ╚═╝╚═════╝ ╚═╝   ╚═╝                         ║"
echo "  ║                                                              ║"
echo "  ║      MindBehindIT MCP Proxy – Installer for macOS            ║"
echo "  ║                                                              ║"
echo "  ╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "  This script will:"
echo "    1. Download the password-protected ZIP"
echo "    2. Unzip it (you will be asked for the password)"
echo "    3. Install the app to your Applications folder"
echo "    4. Remove the quarantine flag (fixes \"unidentified developer\" / Gatekeeper block)"
echo ""
echo "  The password is provided in the release notes or by your administrator."
echo ""

read -rsp "  Enter ZIP password: " PASSWORD
echo ""
echo ""

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "  Downloading..."
if ! curl -fsSL -o "$TMPDIR/MindBehindIT-MCP-Proxy.zip" "$ZIP_URL"; then
  echo "  Error: Failed to download. Check your connection and the download URL." >&2
  exit 1
fi

echo "  Extracting..."
if ! unzip -o -P "$PASSWORD" -q "$TMPDIR/MindBehindIT-MCP-Proxy.zip" -d "$TMPDIR" 2>/dev/null; then
  echo "  Error: Wrong password or corrupted archive." >&2
  exit 1
fi

DMG_PATH="$TMPDIR/$DMG_NAME"
if [[ ! -f "$DMG_PATH" ]]; then
  echo "  Error: DMG not found in archive." >&2
  exit 1
fi

echo "  Mounting DMG..."
MOUNT_POINT=$(hdiutil attach -nobrowse -readonly -quiet -noverify "$DMG_PATH" | tail -1 | awk '{print $3}')
trap 'hdiutil detach -quiet "$MOUNT_POINT" 2>/dev/null; rm -rf "$TMPDIR"' EXIT

echo "  Installing to Applications..."
APP_SRC="$MOUNT_POINT/$APP_NAME"
APP_DST="/Applications/$APP_NAME"

rm -rf "$APP_DST"
cp -R "$APP_SRC" "$APP_DST"

echo "  Unmounting..."
hdiutil detach -quiet "$MOUNT_POINT"

echo "  Removing quarantine flag (allowlisting for macOS Gatekeeper)..."
xattr -cr "$APP_DST"

echo ""
echo "  ✓ Done! MindBehindIT MCP Proxy is installed."
echo "  The app is allowlisted – you can launch it directly from Applications or Spotlight."
echo ""
