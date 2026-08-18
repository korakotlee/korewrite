## Why

Users who dictate or trigger text rewrites via speech-to-text need a fast, non-intrusive preview interface to inspect changes before committing them to active applications.
Without an immediate visual diff HUD, users risk overwriting context without verification.
Implementing a native SwiftUI and AppKit floating HUD modal ensures instant, pixel-perfect verification with keyboard-driven confirmation (`Enter` to apply, `Esc` to dismiss).

## What Changes

- Introduce native SwiftUI diff preview HUD view components rendering side-by-side or inline text diffs.
- Create an AppKit `NSPanel` floating window controller (`.nonactivatingPanel`, `.floating` level) providing translucent glassmorphism background vibrancy.
- Support keybinding shortcuts: `Enter` to commit/apply rewrite, `Esc` to cancel and dismiss HUD.
- Implement animated loading and processing indicators for pending AI rewrite generations.
- Integrate error banner display for failure states such as missing `agy` CLI binary or execution timeouts.

## Capabilities

### New Capabilities
- `diff-preview-hud`: Floating native HUD modal presentation, visual text diff highlighting (additions/deletions), keyboard navigation, and lifecycle state management (loading, diff preview, error).

### Modified Capabilities
<!-- None -->

## Impact

- **UI Layer**: Adds new SwiftUI views and AppKit HUD window hosting controllers in `KoRewriteUI` / `KoRewriteApp`.
- **Core Integration**: Connects with `KoRewriteCore` rewrite pipeline and diff generation utilities.
- **Dependencies**: Native macOS AppKit and SwiftUI frameworks without external heavyweight dependencies.
