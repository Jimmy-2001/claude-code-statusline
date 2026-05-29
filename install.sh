#!/usr/bin/env bash
# Installer for claude-code-statusline.
# Copies the status line script into the Claude config dir and registers it in
# settings.json, preserving any existing settings.
set -euo pipefail

command -v jq >/dev/null 2>&1 || { echo "error: jq is required (try: sudo apt install jq)" >&2; exit 1; }

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
DEST="$CONFIG_DIR/statusline-command.sh"
SETTINGS="$CONFIG_DIR/settings.json"

mkdir -p "$CONFIG_DIR"
cp "$SRC_DIR/statusline-command.sh" "$DEST"
chmod +x "$DEST"
echo "installed: $DEST"

# Merge the statusLine entry into settings.json (create the file if missing).
[ -s "$SETTINGS" ] || echo '{}' > "$SETTINGS"
tmp="$(mktemp)"
jq --arg cmd "bash $DEST" \
   '.statusLine = {type: "command", command: $cmd}' \
   "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
echo "updated:   $SETTINGS"
echo
echo "Done. Restart Claude Code (or run /statusline) to see it."
