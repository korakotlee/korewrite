## 1. Core State & Clipboard Integration

- [x] 1.1 Add `onCopy` callback and `copyText(clipboard:)` method to `HUDViewState`
- [x] 1.2 Write unit tests in `HUDViewStateTests.swift` to verify `copyText()` copies rewritten text and resets status

## 2. UI Button & Key Event Handling

- [x] 2.1 Add "Copy" button with `⌘C` badge and `.keyboardShortcut("c", modifiers: .command)` to `DiffPreviewHUDView` footer
- [x] 2.2 Add `⌘C` key event monitoring and dismissal logic to `HUDPanelController.setupKeyEventMonitor()`
- [x] 2.3 Write unit tests in `HUDPanelControllerTests.swift` verifying `⌘C` key interception and copy triggering

## 3. Verification

- [x] 3.1 Run full test suite `swift test` and verify zero regressions
