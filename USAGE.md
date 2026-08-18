# KoRewrite Usage & Build Guide

## Requirements
- macOS 14.0+ (Tested on macOS Tahoe 26)
- Swift 6.0+ toolchain
- `agy` CLI binary installed and available in `$PATH`

## Building from Source

Build the project and run tests:
```bash
swift build
swift test
```

## Prompt Template Management

### Initialize Default Templates
Seeds default prompts into `~/.korewrite/` (`system.md`, `polite.md`, `professional.md`, `casual.md`, `concise.md`):
```bash
swift run korewrite --init-templates
```

### List Available Rewrite Styles
Scans `~/.korewrite/` dynamically for all available `.md` style templates:
```bash
swift run korewrite --list-styles
```

### Custom Prompt Styles
Create any custom `.md` file inside `~/.korewrite/` (e.g. `~/.korewrite/thai-formal.md`) and it will automatically be recognized by KoRewrite at runtime without restarting or recompiling.
