## Context

The `korewrite` project is a native macOS text-rewriting tool combining a Swift CLI, SwiftUI HUD, and macOS Services / Quick Actions.
`USAGE.md` and `README.md` in the project root are currently empty.
Developers and users require clear, standardized documentation covering prerequisite setup, build commands, automated test runs, macOS service installation, custom preset creation, and debugging.

## Goals / Non-Goals

**Goals:**
- Create a modern, GitHub-styled `README.md` highlighting project capabilities, architecture, and quick start guide.
- Provide a clean, organized `USAGE.md` covering prerequisites, compilation, testing, service installation, prompt configuration, and troubleshooting.
- Supply copy-pasteable terminal commands for common developer workflows (`swift build`, `swift test`, installation scripts).
- Clearly explain macOS security/accessibility permissions and Antigravity (`agy`) CLI integration.
- Document directory layouts for custom prompts located in `~/.korewrite/prompts/`.

**Non-Goals:**
- Documenting internal codebase architecture details (which belong in `docs/ARCHITECTURE.md`).
- Replacing automated installer scripts or packaging logic with manual steps only.

## Decisions

### Decision 1: GitHub-Style Visual Presentation for `README.md`
- **Approach**: Design `README.md` following modern GitHub repository standards, including an introduction banner, key features overview, architecture diagram, fast installation snippet, and reference links to `USAGE.md` and `docs/`.
- **Rationale**: Provides an immediate, polished impression for open source contributors and end-users visiting the GitHub repository.

### Decision 2: Structured Single-File Layout for `USAGE.md`
- **Approach**: Structure `USAGE.md` with a logical table of contents and dedicated sections: Prerequisites, Quick Start, Building from Source, Running Tests, macOS Service Installation, Custom Prompts, and Troubleshooting.
- **Rationale**: Keeps all operational and developer instructions in a single, easily discoverable location.
- **Alternatives Considered**: Splitting instructions across multiple docs was rejected to minimize context switching during local setup.

### Decision 3: Dual Installation Guidance (Script vs Manual)
- **Approach**: Detail the automated installation via `scripts/install_service.sh` while also listing manual copy steps to `~/Library/Services/`.
- **Rationale**: Empowers developers to troubleshoot installation failures or automate workflows in CI/CD environments.

### Decision 4: Actionable Troubleshooting Matrix
- **Approach**: Provide a structured troubleshooting section with diagnostic commands for `agy` path discovery, accessibility permission checks (`tccutil`), and log inspection.
- **Rationale**: Accessibility permissions and CLI binary resolution are the most common points of friction on macOS Tahoe/Sonoma.

## Risks / Trade-offs

- [Risk: CLI path variations on different developer machines] -> Mitigation: Document explicit `PATH` exports and how to verify `which agy`.
- [Risk: macOS Accessibility permission caching issues] -> Mitigation: Provide explicit `tccutil reset Accessibility` guidance and UI navigation paths in System Settings.
