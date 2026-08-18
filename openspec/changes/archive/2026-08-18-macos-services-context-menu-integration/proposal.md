## Why

Currently, KoRewrite requires terminal execution or direct invocation to process text rewrites. Users cannot seamlessly highlight text in any macOS application, right-click, and select a rewrite style directly from the native macOS Services or Quick Actions context menu. This change introduces native macOS Service workflows, selection capture, and clipboard-based in-place text replacement to deliver a frictionless system-wide writing enhancement experience.

## What Changes

- Add macOS Services and Quick Actions (`.workflow` / App Extension / Service bundles) exposing KoRewrite rewrite styles (Professional, Concise, Sriburapa, Story, Thai Official, etc.) in the system right-click context menu.
- Implement selected text capture from the active frontmost application via NSServices / Accessibility APIs / Standard Input.
- Implement clipboard swap and simulated paste (`Cmd+V` via CGEvent / Accessibility) with automatic clipboard restoration for seamless in-place text replacement.
- Integrate active application focus management to return focus and paste the confirmed rewrite into the original target app upon user confirmation in the Diff Preview HUD.
- Implement graceful degradation and error handling when backend CLI dependencies (`korewrite`, `agy`) are missing, misconfigured, or inaccessible.
- Provide installation and registration scripts to deploy Services to `~/Library/Services/` and configure keyboard shortcuts or Quick Action availability.

## Capabilities

### New Capabilities
- `macos-services`: Native macOS Services and Quick Actions integration, frontmost text selection capture, clipboard swapping, and simulated paste in-place replacement across macOS applications.

### Modified Capabilities
<!-- None -->

## Impact

- **New Components:** macOS Services workflows / bundle files, installation scripts (`install-services.sh`), helper service bridge routines in Swift.
- **Affected Systems:** macOS Services system (`~/Library/Services/`), AppKit `NSPasteboard`, CoreGraphics / Accessibility event generation (`CGEventKeyboardPost`).
- **Dependencies:** Interacts with `core-engine` CLI binary and `diff-preview-hud` UI modal.
- **Permissions:** Requires macOS Accessibility permissions (`AXIsProcessTrustedWithOptions`) for simulated keystrokes and focus restoration.
