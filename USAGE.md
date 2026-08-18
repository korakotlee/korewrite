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

## Installation & macOS Services Setup

### 1. Build and Install Binary
Compile the release binary and link it to your `$PATH` (e.g. `~/.local/bin` or `/usr/local/bin`):
```bash
# Build release binary
swift build -c release

# Copy binary to user PATH
mkdir -p ~/.local/bin
cp .build/release/korewrite ~/.local/bin/korewrite
```

### 2. Install Native macOS Services / Quick Actions
Install context menu workflows to `~/Library/Services/` using either the CLI flag or installer script:

```bash
# Option A: Using CLI
korewrite --install-services

# Option B: Using installer script
./scripts/install-services.sh
```

This registers right-click context menu options across macOS applications:
- **KoRewrite - Polite**
- **KoRewrite - Professional**
- **KoRewrite - Concise**
- **KoRewrite - Casual**
- **KoRewrite - Sriburapa**
- **KoRewrite - Story**
- **KoRewrite - Thai Official**

### 3. Grant Accessibility Permissions
For seamless in-place text replacement (`Cmd+V` simulation):
1. Open **System Settings > Privacy & Security > Accessibility**.
2. Enable permissions for **Terminal**, **iTerm**, or **Automator/Services** when prompted.

---

## Running the CLI

### Floating Diff Preview HUD (In-Place Replacement)
Launch the interactive AppKit glassmorphism HUD over the active application:
```bash
echo "Selected text" | korewrite --style professional --hud
```
- **Enter / Return**: Confirm rewrite, restore focus to target app, and paste in-place.
- **Esc**: Dismiss HUD without modifying target application.

### Direct Output via CLI
```bash
# Check AI executable availability
korewrite --check

# Rewrite text via argument
korewrite --style polite --text "can u send me the doc ASAP"
korewrite --style professional --text "hey check this bug out"
korewrite --style concise --text "I am writing this email to let you know that I will be late today"

# Rewrite text via standard input
echo "can u send me the doc ASAP" | korewrite --style polite
```

---

## Prompt Template Management

### Initialize Default Templates
Seeds starter templates into `~/.korewrite/` (`system.md`, `polite.md`, `professional.md`, `casual.md`, `concise.md`, `sriburapa.md`, `story.md`, `thai-official.md`):
```bash
korewrite --init-templates
```

### List Available Rewrite Styles
Scans `~/.korewrite/` dynamically for all available `.md` style templates:
```bash
korewrite --list-styles
```

### Custom Prompt Styles
Create any custom `.md` file inside `~/.korewrite/` (e.g. `~/.korewrite/thai-formal.md`) and it will automatically be discovered by KoRewrite and macOS Services at runtime.

