## 1. Core Diff Engine & State Management

- [x] 1.1 Implement `TextDiffEngine` in pure Swift for tokenizing added, deleted, and unchanged text segments
- [x] 1.2 Implement `HUDViewState` observable model managing loading, diff preview, and error states
- [x] 1.3 Add unit tests covering diff segment generation and state transitions

## 2. SwiftUI Diff Preview Components

- [x] 2.1 Implement `DiffPreviewHUDView` adhering to design tokens, typography, and two-pane/inline diff styling
- [x] 2.2 Implement animated loading and processing indicators for pending CLI rewrites
- [x] 2.3 Implement actionable error banner view for backend execution failures

## 3. AppKit Floating Window Controller & Keybindings

- [x] 3.1 Implement `HUDPanelController` wrapping SwiftUI content in a floating, non-activating `NSPanel`
- [x] 3.2 Wire keyboard event shortcuts for `Enter` (apply) and `Esc` (cancel/dismiss)
- [x] 3.3 Connect confirmation actions to application text insertion callbacks

## 4. Verification & UI Testing

- [x] 4.1 Write integration and snapshot tests for HUD window presentation and keyboard dismissal
- [x] 4.2 Validate Light and Dark appearance rendering against `DESIGN.md` visual tokens
