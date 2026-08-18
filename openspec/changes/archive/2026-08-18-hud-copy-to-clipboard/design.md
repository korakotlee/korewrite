## Context

`KoRewriteCore` provides a floating AppKit `NSPanel` hosting SwiftUI `DiffPreviewHUDView` managed by `HUDViewState` and `HUDPanelController`.
Currently, the preview state allows confirming text insertion via `onApply` (which activates the previous app and runs `PasteSimulator`) or canceling via `onCancel`.
When a user wishes to capture the AI rewrite without replacing in-place, there is no one-click or keyboard shortcut to place the rewritten text onto `NSPasteboard` and cleanly dismiss the HUD.

## Goals / Non-Goals

**Goals:**
- Add a "Copy" button (`⌘C`) to the HUD preview footer alongside Cancel and Apply Rewrite.
- Allow copying either by clicking the button or pressing `⌘C` in the floating panel.
- Write rewritten text to `NSPasteboard.general` via `ClipboardManager` or direct pasteboard call and trigger an `onCopy` lifecycle callback on `HUDViewState`.
- Dismiss the HUD window upon copy without triggering `PasteSimulator` or switching back focus to type/paste.

**Non-Goals:**
- Custom clipboard history management (handled by macOS or clipboard managers).
- Rich text or multi-format clipboard copying (we copy plain string UTF-8).

## Decisions

### Decision 1: Dual shortcut capture in SwiftUI and AppKit event monitor
* **Choice:** Implement `.keyboardShortcut("c", modifiers: .command)` on the SwiftUI `Button` and handle keycode 8 (`kVK_ANSI_C`) + `NSEvent.ModifierFlags.command` in `HUDPanelController.setupKeyEventMonitor()`.
* **Rationale:** The floating HUD is a `.nonactivatingPanel`. AppKit local event monitoring ensures snappy and reliable key interception even when keyboard focus behaves subtly across different host macOS applications.
* **Alternatives considered:** Relying purely on SwiftUI shortcuts (can miss key events if panel does not capture key responder) vs. purely AppKit monitor (lacks visual tooltip/accessibility hint that SwiftUI provides).

### Decision 2: Clipboard write encapsulation in HUDViewState
* **Choice:** Provide `copyText(clipboard: ClipboardManaging = ClipboardManager())` method on `HUDViewState` that writes `rewrittenText` to the clipboard, notifies `onCopy?(rewrittenText)`, and transitions `status` to `.idle`.
* **Rationale:** Centralizing the state transition and clipboard writing in `HUDViewState` keeps the SwiftUI view declarative and facilitates straightforward unit testing with mock pasteboards.
* **Alternatives considered:** Handling clipboard writes solely in the View layer (harder to test and coordinate with AppKit panel controller).

## Risks / Trade-offs

- **[Risk]** Key clash with system copy in case text is selectable inside the diff view.
  - **Mitigation:** Copy button and shortcut copies the whole generated rewrite by default when HUD is in preview mode, which matches user expectations for modal confirmation HUDs.
