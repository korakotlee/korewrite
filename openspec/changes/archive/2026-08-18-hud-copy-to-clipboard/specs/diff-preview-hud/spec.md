cp .build/release/korewrite ~/.local/bin/korewrite## ADDED Requirements

### Requirement: Clipboard Copy Action
The system SHALL provide a dedicated action in the Diff Preview HUD to copy the generated rewritten text to the system pasteboard and dismiss the HUD without modifying or replacing text in the active application.

#### Scenario: User clicks Copy button
- **WHEN** the user clicks the "Copy" button in the HUD preview footer
- **THEN** the system copies the full rewritten text to the macOS general pasteboard and dismisses the HUD immediately.

#### Scenario: User presses ⌘C keyboard shortcut
- **WHEN** the HUD is in preview mode and the user presses `⌘C` (Command-C)
- **THEN** the system copies the rewritten text to the macOS general pasteboard and dismisses the HUD without simulating text replacement.

## MODIFIED Requirements

### Requirement: Keyboard-Driven Confirmation and Dismissal
The system SHALL intercept keyboard shortcuts inside the HUD to confirm text replacement on `Enter`, cancel on `Esc`, and copy text to clipboard on `⌘C`.

#### Scenario: User applies rewrite
- **WHEN** the user presses `Enter` while the HUD is active
- **THEN** the HUD triggers the application callback to insert the rewrite and dismisses immediately.

#### Scenario: User cancels rewrite
- **WHEN** the user presses `Esc` or clicks the cancel button
- **THEN** the HUD cancels the rewrite operation and dismisses without modifying the active application text.

#### Scenario: User triggers copy shortcut
- **WHEN** the user presses `⌘C` while in preview mode
- **THEN** the HUD executes the copy action and dismisses without modifying the active application text.
