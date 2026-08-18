## ADDED Requirements

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
