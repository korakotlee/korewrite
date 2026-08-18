# build-and-usage-docs Specification

## Purpose
TBD - created by archiving change usage-and-build-instructions. Update Purpose after archive.
## Requirements
### Requirement: GitHub-Style Project Readme
The repository SHALL feature a modern, GitHub-styled `README.md` introducing the korewrite system, core features, visual preview/architecture overview, quick start snippet, and navigational links to documentation.

#### Scenario: User visits repository homepage
- **WHEN** a user or contributor views `README.md` on GitHub
- **THEN** the document displays a polished project header, feature highlights (system-wide text rewriting, SwiftUI HUD diff preview, custom prompt templates), system architecture summary, quick start commands, and links to `USAGE.md`.

### Requirement: Prerequisites and Environment Setup Documentation
The `USAGE.md` document SHALL list all required system prerequisites, runtime dependencies, and system permissions needed to build and run korewrite.

#### Scenario: Developer verifies prerequisites
- **WHEN** a developer consults the Prerequisites section in `USAGE.md`
- **THEN** the document clearly details macOS version requirements (macOS 14+), Swift toolchain requirements (Swift 6.0+), Antigravity CLI (`agy`) availability, and Accessibility permission requirements in System Settings.

### Requirement: Source Compilation and Build Instructions
The `USAGE.md` document SHALL provide explicit terminal commands and instructions for compiling the korewrite CLI and macOS Quick Action bundle from source.

#### Scenario: Compiling release binary
- **WHEN** a developer follows the build instructions
- **THEN** the document provides exact commands (`swift build -c release`) and identifies the resulting binary path (`.build/release/korewrite`).

### Requirement: Automated Testing and Quality Verification
The `USAGE.md` document SHALL specify standard test execution commands for running unit, integration, and UI mock tests.

#### Scenario: Running test suite
- **WHEN** a developer executes the documented test commands
- **THEN** `swift test` runs all test suites with instructions on interpreting test outputs and debugging test failures.

### Requirement: macOS Services and Quick Action Installation Guide
The `USAGE.md` document SHALL provide complete step-by-step instructions for installing, updating, and removing korewrite Quick Actions in `~/Library/Services/`.

#### Scenario: Installing Quick Action service
- **WHEN** a user or developer follows the service installation guide
- **THEN** the document details the installation script command and manual installation steps, followed by instructions on activating the service in macOS System Settings Keyboard Shortcuts.

### Requirement: Custom Prompt Preset Configuration Guide
The `USAGE.md` document SHALL explain how to define, organize, and customize user prompt templates in `~/.korewrite/prompts/`.

#### Scenario: Adding a custom rewrite prompt
- **WHEN** a user wants to create a new rewrite mode
- **THEN** the document provides sample markdown prompt files, directory hierarchy, naming conventions, and runtime resolution order.

### Requirement: Troubleshooting and Diagnostics Guide
The `USAGE.md` document SHALL provide actionable solutions for common runtime failures, permission issues, and CLI discovery errors.

#### Scenario: Troubleshooting accessibility permissions or missing agy binary
- **WHEN** a user encounters permission errors (`tccutil reset Accessibility`) or missing `agy` CLI binary errors
- **THEN** the document provides exact diagnostic commands, log inspection steps, and remediation steps.

