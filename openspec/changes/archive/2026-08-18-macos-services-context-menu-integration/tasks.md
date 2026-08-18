## 1. Service Workflows & Installation

- [x] 1.1 Create macOS Quick Action / Service workflow definitions for available rewrite styles (Professional, Concise, Sriburapa, Story, Thai Official) in `services/`.
- [x] 1.2 Implement `scripts/install-services.sh` and CLI subcommand to deploy workflow bundles to `~/Library/Services/` and register them with `pbs`.

## 2. Active Application & Selection Ingestion

- [x] 2.1 Implement `ActiveAppTracker` to record the frontmost application PID and bundle identifier when a Service is triggered.
- [x] 2.2 Configure CLI pipeline to read highlighted text selection from standard input (`stdin`) seamlessly into the rewrite engine.

## 3. In-Place Replacement & Clipboard Management

- [x] 3.1 Implement `ClipboardManager` to snapshot existing `NSPasteboard` items and safely restore them post-paste.
- [x] 3.2 Implement `PasteSimulator` to post `Cmd+V` key events via `CGEvent` with `AXIsProcessTrustedWithOptions` permission checks.
- [x] 3.3 Wire HUD confirmation action to activate the target application and dispatch in-place replacement.

## 4. Verification & Testing

- [x] 4.1 Add unit and integration tests for `ClipboardManager` state restoration and service argument parsing.
- [x] 4.2 Verify in-place replacement workflow across Safari, Google Chrome, Slack, VS Code, and Apple Notes.
