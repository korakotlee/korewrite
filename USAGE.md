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

## Running the CLI

### Check AI Executable Availability
```bash
swift run korewrite --check
```

### Rewrite Text via Argument
```bash
swift run korewrite --style polite --text "can u send me the doc ASAP"
swift run korewrite --style professional --text "hey check this bug out"
swift run korewrite --style concise --text "I am writing this email to let you know that I will be late today"
```

### Rewrite Text via Standard Input
```bash
echo "can u send me the doc ASAP" | swift run korewrite --style polite
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
