## Context

KoRewrite provides a swift CLI engine, prompt library, and a floating AppKit Diff Preview HUD. To provide a first-class macOS user experience, KoRewrite must integrate with the native macOS Services and Quick Actions menu accessible via right-click contextual menus or keyboard shortcuts across macOS applications.

## Goals / Non-Goals

**Goals:**
- Provide native macOS Services / Quick Action workflows for 5-6 core rewrite styles.
- Extract selected text directly via standard macOS Service input (`NSSendTypes` / stdin).
- Retain reference to target application and re-activate it upon HUD confirmation.
- Execute in-place text replacement via clipboard swap, simulated `Cmd+V` paste event, and automatic clipboard state restoration.
- Provide a setup command (`korewrite install-services` or `scripts/install-services.sh`) to generate and deploy workflows into `~/Library/Services/`.
- Handle missing `agy` or execution errors gracefully with notifications or HUD error alerts.

**Non-Goals:**
- Implementing an invasive global keyboard hook daemon.
- Custom Accessibility text rewriting for non-standard UI controls that do not support clipboard paste (`Cmd+V`).
- Cloud syncing of service shortcuts.

## Decisions

### 1. Packaging Services as Automator Workflows / Quick Actions
- **Decision:** Build modular `.workflow` bundles under `~/Library/Services/` configured with `NSMessage = runWorkflowAsService` and `NSSendTypes = (NSStringPboardType)`.
- **Rationale:** Automator workflow bundles integrate directly into the macOS Services menu across all Cocoa and WebKit apps without requiring complex App Sandbox entitlements.
- **Alternatives Considered:** Standalone Accessibility daemon (higher permission overhead, rejected); macOS App Extension (requires full app bundle packaging and sandboxing restrictions).

### 2. Selection Capture via Standard Input & Service Pipeline
- **Decision:** Pass the highlighted text selection directly from the Service runner to `korewrite --style <style> --hud` via standard input (`stdin`).
- **Rationale:** Ensures clean, lossless UTF-8 text transfer without intermediate temporary files or clipboard pollution prior to user approval.

### 3. Clipboard Preservation and Simulated In-Place Paste
- **Decision:** Use `NSPasteboard.general` with a temporary snapshot:
  1. Snapshot existing pasteboard items (`types` and `data(forType:)`).
  2. Put confirmed rewritten text on the pasteboard.
  3. Re-activate the captured target application (`NSRunningApplication.activate(options:)`).
  4. Post `CGEvent` keyboard events for `Cmd+V` (key code 9 with `.maskCommand`).
  5. Schedule pasteboard restoration after a short delay (150ms).
- **Rationale:** Standardized across macOS editors (Safari, Chrome, Notes, Slack, VS Code).
- **Alternatives Considered:** Accessibility AXUIElementSetValue (fails on web views and rich text controls; clipboard paste is universal).

### 4. Service Deployment & Management Tooling
- **Decision:** Provide CLI subcommand `korewrite install-services` and shell installer `scripts/install-services.sh` to compile/copy workflow bundles to `~/Library/Services/` and trigger `pbs -flush` or system service refresh.
- **Rationale:** Gives users a single-command setup experience with automatic discovery of local binary paths.

## Risks / Trade-offs

- **[Risk] Accessibility Permissions:** Simulated keyboard events via `CGEventPost` require macOS Accessibility permissions.
  - *Mitigation:* Check `AXIsProcessTrustedWithOptions` on invocation and prompt the user to grant permission in System Settings if not enabled.
- **[Risk] Race Condition in Clipboard Restoration:** Restoring the clipboard before the target app processes `Cmd+V` could paste previous clipboard content.
  - *Mitigation:* Ensure target app activation is confirmed, dispatch paste event, and delay pasteboard restore by 150-200ms asynchronously.
- **[Risk] Missing AI Engine (`agy`):** If `agy` is not installed or not in `/usr/local/bin` / `~/.agy/bin` / `PATH`, invocation will fail.
  - *Mitigation:* Validate dependencies on startup and display an informative HUD alert or system notification.

## Migration Plan

1. Create workflow definitions in `services/` template directory.
2. Implement clipboard manager and paste simulator helper in `Sources/KoRewrite/Service/`.
3. Implement `install-services` CLI command and installer script.
4. Verify with automated unit tests and manual cross-app testing matrix.
