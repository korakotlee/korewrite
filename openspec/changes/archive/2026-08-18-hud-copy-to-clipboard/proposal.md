## Why

Currently, the floating Diff Preview HUD only offers "Cancel" (`Esc`) and "Apply Rewrite" (`Enter`). When users want to copy the rewritten text to use elsewhere or keep their original text intact, they have to manually select and copy text from the preview or apply and undo in-place. Adding a dedicated "Copy" action with `⌘C` shortcut allows users to copy the generated rewrite directly to the clipboard and dismiss the HUD without overwriting their active editor selection.

## What Changes

- Add a "Copy" button (`⌘C`) in the footer of `DiffPreviewHUDView`.
- Support `⌘C` keyboard shortcut via SwiftUI `.keyboardShortcut` and AppKit local event monitor in `HUDPanelController`.
- Introduce `copy()` / `copyText()` method and `onCopy` lifecycle callback in `HUDViewState` to write rewritten text to `NSPasteboard` and transition to idle state.
- Ensure the floating HUD dismisses smoothly upon copying without simulating paste keystrokes in the active application.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `diff-preview-hud`: Add copy to clipboard button and `⌘C` shortcut behavior in preview mode to copy rewritten text to clipboard and dismiss the HUD without modifying active editor selection.

## Impact

- `Sources/KoRewriteCore/HUD/DiffPreviewHUDView.swift`: Footer button additions and keyboard shortcut bindings.
- `Sources/KoRewriteCore/HUD/HUDViewState.swift`: New `onCopy` callback and `copyText()` action handler.
- `Sources/KoRewriteCore/HUD/HUDPanelController.swift`: Keycode 8 (`⌘C`) monitor interception and panel dismissal.
- `Tests/KoRewriteCoreTests/HUDViewStateTests.swift` & `HUDPanelControllerTests.swift`: Extended unit test coverage for copy operations.
