# claude-code-statusline

A minimal, dependency-light [Claude Code](https://claude.com/claude-code) status line.

Two lines, styled after a typical bash `PS1`:

```
jimmy@machine:/home/jimmy/works/data_extractor
Opus · high · context 60% left
```

- **`user@host:cwd`** — bold green / bold blue, like your shell prompt.
- **model** — from the status line payload (e.g. `Opus`, `Sonnet`).
- **effort** — read from `effortLevel` in your Claude settings (omitted if unset).
- **`context NN% left`** — context window *remaining*, estimated from the latest
  turn's input-side tokens (`input + cache_read + cache_creation`) against a
  200k window. Output tokens are excluded.

No third-party tools, no network calls. Just `bash` + `jq`.

## Install

```bash
git clone https://github.com/Jimmy-2001/claude-code-statusline.git
cd claude-code-statusline
./install.sh
```

`install.sh` copies `statusline-command.sh` into your Claude config dir
(`$CLAUDE_CONFIG_DIR`, default `~/.claude`) and wires up the `statusLine` entry
in `settings.json` — preserving any existing settings.

### Manual install

1. Copy `statusline-command.sh` somewhere (e.g. `~/.claude/statusline-command.sh`) and `chmod +x` it.
2. Add to `~/.claude/settings.json`:

   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "bash ~/.claude/statusline-command.sh"
     }
   }
   ```

## Customize

Edit `statusline-command.sh`:

- **Context window** — change `CONTEXT_WINDOW=200000` (set to `1000000` for Sonnet's 1M-context beta).
- **Show context *used* instead of remaining** — drop the `100 - ( ... )` wrapper in the `ctx` block.
- **Colors** — the ANSI codes in the final two `printf` lines (`01;32` green, `01;34` blue, `02` dim).

## Notes

- **effort** reflects the persisted `effortLevel` setting, not a per-session `/effort` override.
- This shows your local context estimate only. Your account's official 5h / weekly
  usage limits are server-side and not available to status line scripts — use
  `/usage` inside Claude Code for those.

## Requirements

`bash` and `jq` (`sudo apt install jq` on Debian/Ubuntu/WSL).
