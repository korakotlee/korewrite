# design-system Specification

## Purpose
Define the visual design system, token definitions, typography rules, layout hierarchy, and UI interaction specifications for KoRewrite.
## Requirements
### Requirement: Design Token Architecture and Color Palettes
The design system SHALL specify semantic design tokens for both macOS Light and Dark modes, encompassing window background materials, borders, primary/secondary text, and diff highlighting.

#### Scenario: Light mode color palette
- **WHEN** the system operates in Light appearance
- **THEN** the design tokens define high-contrast background surfaces, subtle light-gray borders, legible dark-gray body text, soft green tint for diff additions, and soft red tint for diff deletions.

#### Scenario: Dark mode color palette
- **WHEN** the system operates in Dark appearance
- **THEN** the design tokens define dark translucent material backgrounds, subtle dark-mode borders, crisp light body text, high-legibility emerald tint for diff additions, and coral/rose tint for diff deletions.

### Requirement: Typography System
The design system SHALL specify typography rules adhering to Apple Human Interface Guidelines (HIG), utilizing SF Pro for interface elements and SF Mono for text diff representations.

#### Scenario: System font hierarchy
- **WHEN** rendering HUD labels, headers, and buttons
- **THEN** SF Pro typography styles (Headline, Body, Caption, Subhead) with defined point sizes, weights, and line heights MUST be applied.

#### Scenario: Code and diff font styling
- **WHEN** rendering original and rewritten text diff blocks
- **THEN** SF Mono typography with fixed tracking and tabular alignment MUST be applied to ensure character alignment.

### Requirement: Floating Confirmation HUD Modal Layout and Keybindings
The design system SHALL document the exact layout structure, sizing constraints, button placements, and keyboard interactions for the floating diff confirmation HUD modal.

#### Scenario: Modal layout and controls
- **WHEN** the preview HUD is presented to the user
- **THEN** it SHALL display a structured two-pane or inline diff view, accompanied by a primary `[Apply]` button and a secondary `[Cancel]` button.

#### Scenario: Keyboard shortcuts
- **WHEN** the HUD has active keyboard focus
- **THEN** pressing `Enter` triggers the Apply action and pressing `Esc` triggers the Cancel action.

### Requirement: Micro-Animations and Visual Transitions
The design system SHALL specify standard macOS animation curves, spring durations, and transition parameters for window appearance, dismissals, and button state interactions.

#### Scenario: Window presentation animation
- **WHEN** the HUD window is summoned
- **THEN** it SHALL animate using a fast subtle scale-up and fade-in (150-200ms ease-out) consistent with native macOS system panels.

### Requirement: Error and Offline States
The design system SHALL specify visual feedback standards for processing states, errors, and disabled indicators when the `agy` backend is unreachable or fails.

#### Scenario: Backend unavailable indicator
- **WHEN** `agy` CLI binary is missing or unreachable
- **THEN** the system UI SHALL present a dimmed/disabled status badge or context menu indicator with actionable error messaging.

