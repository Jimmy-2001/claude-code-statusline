#!/usr/bin/env bash
# Claude Code statusLine
#   line 1: PS1-style  user@host:cwd   (bold green / bold blue, like a typical bash PS1)
#   line 2: model · effort · ctx NN% left   (dim)
#
# Input: JSON via stdin (Claude Code statusLine protocol).
# Dependencies: bash, jq. No third-party tools, no network — fully portable.

input=$(cat)
CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SETTINGS="$CONFIG_DIR/settings.json"
CONTEXT_WINDOW=200000   # token budget; set to 1000000 for Sonnet's 1M-context beta

# ---- line 1: location (mirrors a bash PS1) ------------------------------
cwd=$(printf '%s' "$input" | jq -r '.cwd // .workspace.current_dir // empty')
[ -z "$cwd" ] && cwd="$(pwd)"

# ---- model (from payload) + effort (from settings; not in payload) ------
model=$(printf '%s' "$input" | jq -r '.model.display_name // .model.id // "?"')
effort=$(jq -r '.effortLevel // empty' "$SETTINGS" 2>/dev/null)

# ---- context REMAINING %: 100 - (latest-turn input-side tokens / window)-
# The most recent turn's input + cache_read + cache_creation tokens are
# everything currently occupying the context window; output is excluded.
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty')
ctx=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
    ctx=$(tail -n 80 "$transcript" 2>/dev/null | jq -s -r --argjson win "$CONTEXT_WINDOW" '
        [ .[] | .message.usage? // empty ] | last as $u
        | if $u == null then empty
          else (100 - (($u.input_tokens // 0)
                       + ($u.cache_read_input_tokens // 0)
                       + ($u.cache_creation_input_tokens // 0)) * 100 / $win)
               | floor | (if . < 0 then 0 else . end)
          end' 2>/dev/null)
fi

# ---- assemble line 2 (dim) ----------------------------------------------
parts="$model"
[ -n "$effort" ] && parts="$parts · $effort"
[ -n "$ctx" ]    && parts="$parts · context ${ctx}% left"

# ---- emit ----------------------------------------------------------------
printf '\033[01;32m%s@%s\033[00m:\033[01;34m%s\033[00m\n' \
    "$(whoami)" "$(hostname -s)" "$cwd"
printf '\033[02m%s\033[00m' "$parts"
