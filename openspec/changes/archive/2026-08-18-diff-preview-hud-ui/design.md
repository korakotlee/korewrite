## Context

KoRewrite operates as a system-wide writing assistant triggered via hotkeys or speech-to-text dictation.
Users need to review rewrites before text gets pasted into their active window.
This design defines the architecture for the floating HUD modal, diff rendering pipeline, keyboard handlers, and state management.

## Goals / Non-Goals

**Goals:**
- Provide a native, lightweight AppKit floating HUD panel (`NSPanel`) that does not steal full application focus.
- Render high-performance visual diffs highlighting added and removed text fragments using SF Mono typography.
- Enable instantaneous keyboard interaction (`Enter` to confirm, `Esc` to dismiss).
- Manage loading and error states smoothly with animated indicators.

**Non-Goals:**
- Rich-text interactive WYSIWYG editing inside the preview HUD (the HUD is a preview and confirmation surface).
- Full syntax highlighting for multi-language code files (handled via standard monospace diff highlighting).

## Decisions

### Decision: Native AppKit `NSPanel` Hosting SwiftUI Views
- **Choice**: Wrap SwiftUI `DiffPreviewHUDView` inside an `NSPanel` with `.nonactivatingPanel` style mask and `.floating` window level.
- **Rationale**: Avoids stealing focus from the active foreground app (e.g., Xcode, Slack, browser), allowing seamless text insertion upon confirmation.
- **Alternatives Considered**: Standard `NSWindow` (steals focus and causes flicker), Electron/Webview overlay (heavy memory footprint and slow cold start).

### Decision: In-Memory Word and Character Diff Algorithm
- **Choice**: Implement a lightweight pure Swift Myers/LCS diff generator producing tokenized diff blocks (`addition`, `deletion`, `unchanged`).
- **Rationale**: Zero external binary or heavy dependency requirements; runs in < 5ms for typical paragraph-length rewrite inputs.
- **Alternatives Considered**: Shelling out to `git diff` or `diff` CLI (process spawning latency overhead).

### Decision: Local Event Monitoring for Keybindings
- **Choice**: Combine SwiftUI `.keyboardShortcut(.defaultAction)` / `.keyboardShortcut(.cancelAction)` with AppKit local key event monitor fallback.
- **Rationale**: Guarantees responsive `Enter` and `Esc` triggers even when panel has non-activating status.

## Risks / Trade-offs

- **[Risk]** Non-activating floating panel might miss key events if another application aggressively traps keystrokes.
  → **Mitigation**: Register local event monitors and provide clearly clickable button targets.
- **[Risk]** Large text rewrites could cause diff calculation lags or overflow HUD frame bounds.
  → **Mitigation**: Add scrollable diff containers with bounded maximum dimensions (e.g., max width 640pt, max height 480pt) and async diff tokenization.
