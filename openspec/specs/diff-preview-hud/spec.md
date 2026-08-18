# diff-preview-hud Specification

## Purpose
Define the floating diff preview HUD presentation, visual diff highlighting, keyboard shortcuts, and state management for KoRewrite.

## Requirements

### Requirement: Floating HUD Presentation and Translucency
The system SHALL present a floating HUD window modal utilizing native AppKit `NSPanel` floating window hosting with translucent material vibrancy and non-activating focus.

#### Scenario: Display floating HUD panel
- **WHEN** a diff preview presentation request is triggered
- **THEN** the system displays a non-activating floating HUD window styled with glassmorphic vibrancy centered above active windows.

### Requirement: Visual Diff Rendering
The system SHALL render a visual diff highlighting deletions in original input text and additions in rewritten text using SF Mono typography and semantic palette tokens.

#### Scenario: Side-by-side or inline diff highlight
- **WHEN** original text and rewritten text differ
- **THEN** the HUD highlights deletions in red/coral background tones and additions in green/emerald background tones with monospace font alignment.

### Requirement: Keyboard-Driven Confirmation and Dismissal
The system SHALL intercept keyboard shortcuts inside the HUD to confirm text replacement on `Enter` and cancel on `Esc`.

#### Scenario: User applies rewrite
- **WHEN** the user presses `Enter` while the HUD is active
- **THEN** the HUD triggers the application callback to insert the rewrite and dismisses immediately.

#### Scenario: User cancels rewrite
- **WHEN** the user presses `Esc` or clicks the cancel button
- **THEN** the HUD cancels the rewrite operation and dismisses without modifying the active application text.

### Requirement: Loading and Async State Management
The system SHALL display an animated progress state while waiting for AI rewrite results from the CLI backend.

#### Scenario: Processing rewrite request
- **WHEN** a rewrite command is actively executing
- **THEN** the HUD displays an animated loading spinner or pulsing indicator alongside the original text.

### Requirement: Error Feedback and Recovery
The system SHALL render an actionable error banner when CLI execution fails, times out, or encounters a missing binary.

#### Scenario: Backend execution error
- **WHEN** the CLI engine reports an error or missing binary
- **THEN** the HUD displays an error alert badge describing the failure and offers a dismiss action.
