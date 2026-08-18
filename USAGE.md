# KoRewrite Usage & Build Guide

Comprehensive developer workflow, build instructions, test run guide, macOS Services installation, and troubleshooting for KoRewrite.

---

## Table of Contents

- [1. Prerequisites & System Requirements](#1-prerequisites--system-requirements)
- [2. macOS Security & Accessibility Permissions](#2-macos-security--accessibility-permissions)
- [3. Building from Source](#3-building-from-source)
- [4. Running Automated Tests](#4-running-automated-tests)
- [5. macOS Services & Quick Actions Installation](#5-macos-services--quick-actions-installation)
- [6. CLI Commands & Interactive HUD](#6-cli-commands--interactive-hud)
- [7. Custom Prompt Template Management](#7-custom-prompt-template-management)
- [8. Troubleshooting & Diagnostics](#8-troubleshooting--diagnostics)

---

## 1. Prerequisites & System Requirements

Before building or running KoRewrite, ensure your environment meets the following requirements:

- **Operating System**: macOS 14.0 (Sonoma) or macOS Tahoe 26+
- **Compiler Toolchain**: Swift 6.0+ toolchain (included with Xcode 16+ or Command Line Tools)
- **AI Backend**: Antigravity (`agy`) CLI binary installed and available in `$PATH`
- **Shell**: zsh / bash

Verify your local toolchain:

```bash
# Verify Swift version
swift --version

# Verify Antigravity CLI binary
which agy || echo "agy not found in PATH"
```

---

## 2. macOS Security & Accessibility Permissions

KoRewrite requires macOS Accessibility and System Events automation permissions to capture selected text and perform simulated in-place paste (`Cmd+V`) operations.

### Granting Accessibility Access

1. Open **System Settings**.
2. Navigate to **Privacy & Security** > **Accessibility**.
3. Enable the toggle for the hosting application:
   - **Terminal.app** or **iTerm.app** (during local development and CLI testing)
   - **Automator.app** / **Services** (when invoked via right-click Quick Actions)
   - Any custom application invoking the helper binary

### Resetting Permissions (if needed)

If macOS permission caches become stale after rebuilding binaries:

```bash
# Reset Accessibility permissions for Terminal
tccutil reset Accessibility com.apple.Terminal

# Reset Accessibility permissions globally
tccutil reset Accessibility
```

---

## 3. Building from Source

KoRewrite is built using Swift Package Manager (SPM).

### Development Debug Build

```bash
# Clone the repository (if not already local)
git clone https://github.com/korakot/korewrite.git
cd korewrite

# Compile debug executable
swift build
```

The debug binary is located at:
`.build/debug/korewrite`

### Optimized Release Build

```bash
# Build optimized release binary
swift build -c release
```

The compiled release binary is located at:
`.build/release/korewrite`

### Installing to Local User PATH

```bash
mkdir -p ~/.local/bin
cp .build/release/korewrite ~/.local/bin/korewrite
chmod +x ~/.local/bin/korewrite
```

Ensure `~/.local/bin` is in your shell `$PATH`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

---

## 4. Running Automated Tests

KoRewrite uses Swift Testing (`swift test`) for unit, integration, and UI mock tests.

### Execute Entire Test Suite

```bash
swift test
```

### Run Tests with Parallel Execution Disabled (Debug Mode)

```bash
swift test --parallel false
```

### Filter Specific Test Targets

```bash
# Run only Prompt Engine tests
swift test --filter PromptEngineTests

# Run only CLI parsing tests
swift test --filter CLIParsingTests
```

---

## 5. macOS Services & Quick Actions Installation

KoRewrite registers native macOS Quick Actions inside `~/Library/Services/` so that rewrite presets appear in the right-click context menu across all Mac applications (Mail, Slack, Notes, Safari, Chrome, VS Code).

### Automated Installation (Recommended)

Run the included installer script:

```bash
./scripts/install-services.sh
```

Or invoke the built-in CLI installation flag:

```bash
korewrite --install-services
```

### Manual Installation Steps

If installing manually:

1. Compile the release binary:
   ```bash
   swift build -c release
   ```
2. Copy workflow bundles into user Services:
   ```bash
   mkdir -p ~/Library/Services
   cp -R templates/*.workflow ~/Library/Services/
   ```
3. Refresh the macOS Services registration cache:
   ```bash
   /System/Library/CoreServices/pbs -flush
   ```

### Enabling in Keyboard Shortcuts

1. Open **System Settings** > **Keyboard** > **Keyboard Shortcuts...**.
2. Select **Services** from the sidebar.
3. Expand **Text** and check the box next to each **KoRewrite - [Style]** entry.
4. (Optional) Assign a custom global keyboard shortcut to your favorite rewrite style (e.g. `Cmd + Shift + R`).

---

## 6. CLI Commands & Interactive HUD

### Checking AI Backend Availability

```bash
korewrite --check
```

### Interactive Glassmorphic Floating HUD (Diff Preview)

Pipe text directly into the HUD to preview original vs rewritten text with visual diff highlighting before applying:

```bash
echo "can u send me the doc ASAP" | korewrite --style professional --hud
```

- **Enter / Return**: Apply rewrite, copy replacement to clipboard, and paste in-place.
- **Esc**: Dismiss HUD without modifying active text.

### Direct CLI Output

Rewrite text directly to stdout:

```bash
# Rewrite via CLI argument
korewrite --style polite --text "can u send me the doc ASAP"
korewrite --style professional --text "hey check this bug out"
korewrite --style concise --text "I am writing this email to let you know that I will be late today"

# Rewrite via standard input
echo "can u send me the doc ASAP" | korewrite --style polite
```

---

## 7. Custom Prompt Template Management

KoRewrite dynamically loads prompt templates from `~/.korewrite/`.

### Initializing Default Presets

Seeds default starter templates (`system.md`, `polite.md`, `professional.md`, `casual.md`, `concise.md`, `sriburapa.md`, `story.md`, `thai-official.md`):

```bash
korewrite --init-templates
```

### Listing Active Styles

```bash
korewrite --list-styles
```

### Adding a Custom Preset

Create a new markdown file in `~/.korewrite/` (e.g. `~/.korewrite/executive.md`):

```markdown
# Role: Executive Summary Rewriter

Rewrite the selected text for high-level executive communication:
- Lead with key findings, decisions, or action items.
- Remove technical implementation minutiae.
- Maintain a clear, authoritative, and concise tone.
```

The new style `executive` is immediately available to the CLI (`korewrite --style executive`) and right-click Services menu without recompiling.

---

## 8. Troubleshooting & Diagnostics

### Missing `agy` Binary

**Symptom**: `korewrite --check` reports `agy executable not found`.

**Resolution**:
1. Check if `agy` is installed:
   ```bash
   which agy
   ```
2. If `agy` is installed in a non-standard location (e.g. `/opt/homebrew/bin/agy`), ensure your shell startup profile (`~/.zshrc` or `~/.bash_profile`) exports the path:
   ```bash
   export PATH="/opt/homebrew/bin:$PATH"
   ```

### Accessibility Permission Failures

**Symptom**: The HUD closes upon pressing Enter, but the text in the target app is not replaced.

**Resolution**:
1. Verify that the parent app has Accessibility permission in **System Settings** > **Privacy & Security** > **Accessibility**.
2. If permissions were previously granted but stopped working after an update, reset the permission database:
   ```bash
   tccutil reset Accessibility
   ```
3. Restart the host application and re-grant permissions when prompted.

### Inspecting Logs

KoRewrite logs execution details to standard error and system logs:

```bash
# Run with debug verbosity
korewrite --style polite --text "test input" --verbose
```
