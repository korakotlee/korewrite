# macos-services Specification

## Purpose
TBD - created by archiving change macos-services-context-menu-integration. Update Purpose after archive.
## Requirements
### Requirement: macOS Services and Quick Actions Definitions
The system SHALL provide macOS Service / Quick Action definitions (`.workflow` / NSServices configuration) registered in `~/Library/Services/` for all supported KoRewrite prompt styles.

#### Scenario: User opens Services contextual menu
- **WHEN** the user selects text in any standard macOS application and opens the right-click contextual Services or Quick Actions menu
- **THEN** the system displays KoRewrite action items corresponding to available rewrite styles (e.g., "KoRewrite: Professional", "KoRewrite: Concise", "KoRewrite: Sriburapa", "KoRewrite: Story", "KoRewrite: Thai Official").

### Requirement: Active Text Selection Capture
The system SHALL capture the highlighted text selection from the active frontmost application when a KoRewrite Service is invoked.

#### Scenario: Extract highlighted text from frontmost app
- **WHEN** a KoRewrite Service action is selected from the context menu or triggered by a hotkey
- **THEN** the system captures the current selected text string and the bundle identifier / PID of the active frontmost application.

### Requirement: In-Place Text Replacement via Clipboard Swapping
The system SHALL replace the original selected text in-place by preserving existing clipboard state, copying the rewritten text into the pasteboard, synthesizing a `Cmd+V` paste event to the target application, and restoring the original clipboard content.

#### Scenario: User confirms rewritten text in HUD
- **WHEN** the user accepts a rewrite in the Diff Preview HUD
- **THEN** the system activates the original target application, places the rewritten text onto `NSPasteboard.general`, simulates `Cmd+V` keypress event, and subsequently restores previous clipboard contents.

#### Scenario: User dismisses or cancels HUD
- **WHEN** the user cancels or dismisses the Diff Preview HUD
- **THEN** the system leaves the active application text and existing clipboard unchanged.

### Requirement: Graceful Degradation on Backend Availability
The system SHALL detect whether the required CLI engine (`korewrite`) or AI backend (`agy`) is available and accessible before attempting rewrite operations, displaying an informative notification or HUD banner if missing.

#### Scenario: Backend CLI or agy is unavailable
- **WHEN** a service is triggered but `agy` or `korewrite` is not present in `PATH` or configured location
- **THEN** the system displays a native macOS user notification or HUD error alert instructing how to install or configure dependencies without modifying user text.

### Requirement: Multi-Application Compatibility
The system SHALL support in-place text replacement across standard macOS text editors and applications including Safari, Google Chrome, Slack, VS Code, and Apple Notes.

#### Scenario: Executing rewrite in rich or web editors
- **WHEN** text is selected and rewritten within Safari, Chrome, Slack, VS Code, or Apple Notes
- **THEN** the text replacement completes cleanly in-place without corrupting surrounding editor contents.

### Requirement: Dynamic Services Synchronization and Refresh
The system SHALL support dynamic synchronization of installed macOS Service workflows (`~/Library/Services/KoRewrite - *.workflow`) with active markdown templates in `~/.korewrite/` via a `--refresh` CLI flag or `refresh` subcommand.

#### Scenario: Running refresh command
- **WHEN** the user executes `korewrite --refresh` or `korewrite refresh`
- **THEN** the system scans `~/.korewrite/` for active style templates, updates or creates corresponding `.workflow` bundles in `~/Library/Services/`, removes orphan workflow bundles for deleted styles, and triggers a pasteboard cache flush (`pbs -flush`).

#### Scenario: Orphan workflow cleanup
- **WHEN** a style markdown template has been deleted from `~/.korewrite/` and `korewrite --refresh` is invoked
- **THEN** the system removes the corresponding legacy `KoRewrite - *.workflow` bundle from `~/Library/Services/` while preserving workflows belonging to active styles.

#### Scenario: Pasteboard service cache flush
- **WHEN** services are installed or refreshed
- **THEN** the system invokes `/System/Library/CoreServices/pbs -flush` to immediately update the macOS context menu without requiring a system restart or user log out.


