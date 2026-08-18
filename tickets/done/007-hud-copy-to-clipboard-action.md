**Type:** [x] UI / UX  |  [x] Feature Request

---

### 1. Summary
Add a "Copy" button with `⌘C` keyboard shortcut to the Diff Preview HUD, allowing users to copy the rewritten text to the system clipboard and dismiss the HUD without performing in-place text replacement.

### 2. Context & Problem
* **Current Behavior:** The Diff Preview HUD only provides "Cancel" (`Esc`) and "Apply Rewrite" (`Return`) buttons. "Apply Rewrite" automatically overwrites and replaces the selected text in the active application.
* **Expected Behavior:** Users who want to retain the original text or paste the AI rewrite into a different application or field can click a dedicated "Copy" button (or press `⌘C`) to copy the generated text to the system clipboard and close the HUD without replacing the active selection.

### 3. Proposed Solution / Acceptance Criteria
- [x] Add a "Copy" / "Copy Text" action button (`⌘C`) in the footer of `DiffPreviewHUDView` alongside "Cancel" and "Apply Rewrite".
- [x] Bind keyboard shortcut `⌘C` in both SwiftUI (`.keyboardShortcut("c", modifiers: .command)`) and the AppKit floating panel local key monitor (`HUDPanelController`).
- [x] Implement `copy()` action handler in `HUDViewState` and `HUDPanelController` to write `rewrittenText` to `NSPasteboard.general` (or via `ClipboardManager`) and transition state to idle.
- [x] Ensure copying dismisses the HUD panel cleanly without invoking `PasteSimulator` or modifying the focused application's text.
- [x] Add unit tests verifying `HUDViewState` copy callback/state lifecycle and `HUDPanelController` event interception.

### 4. Technical Context / Notes
* **Affected Areas:** 
  - `Sources/KoRewriteCore/HUD/DiffPreviewHUDView.swift` (UI button & shortcut)
  - `Sources/KoRewriteCore/HUD/HUDViewState.swift` (State management & `onCopy` handler)
  - `Sources/KoRewriteCore/HUD/HUDPanelController.swift` (Local key monitor for `⌘C` + dismissal)
  - `Tests/KoRewriteCoreTests/HUDViewStateTests.swift` & `HUDPanelControllerTests.swift` (Unit tests)
* **Suggested Approach / Architectural Hints:**
  - Update `HUDViewState` to include `public var onCopy: (@Sendable (String) -> Void)?` and `public func copyText()`.
  - In `HUDPanelController.setupKeyEventMonitor()`, intercept keycode 8 (`kVK_ANSI_C`) when `event.modifierFlags.contains(.command)` and `status` is `.preview`.
  - Integrate clipboard writing using `NSPasteboard.general` or `ClipboardManager.write(text:)`.
* **Blockers or Dependencies:** None (builds on existing HUD framework from [004-diff-preview-hud-ui.md](file:///Users/korakot/dev/korewrite/tickets/done/004-diff-preview-hud-ui.md)).

### 5. Alternatives Considered
* **Manual text selection inside HUD:** Require the user to highlight text inside the result preview and press `⌘C`. Rejected because it requires extra clicks, is error-prone, and doesn't auto-dismiss the floating panel.
* **Secondary dropdown menu:** Add copy as an overflow action. Rejected because copy is a primary action alongside Apply and Cancel.

### 6. Visuals & Logs (Optional)
* Proposed Footer layout:
  `[ Cancel (⎋) ]`  ----------------------  `[ Copy (⌘C) ]` `[ Apply Rewrite (↵) ]`
