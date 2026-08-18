**Type:** [x] Feature Request

---

### 1. Summary
Write comprehensive build instructions, local development workflow, and test run guide in `USAGE.md`.

### 2. Context & Problem
* **Current Behavior:** `USAGE.md` is currently empty with no documentation on how to build from source, install services, or run tests while coding.
* **Expected Behavior:** `USAGE.md` contains clear, step-by-step developer instructions to build binaries, run automated test suites, install Quick Actions to macOS Services, and test live rewriting.

### 3. Proposed Solution / Acceptance Criteria
- [x] Document prerequisites and required macOS permissions (Accessibility).
- [x] Provide command to build the project from source (`swift build -c release`).
- [x] Provide command to execute automated unit and integration tests (`swift test`).
- [x] Detail the one-line installer command to install/update Services in `~/Library/Services/`.
- [x] Document how to add custom prompt files in `~/.korewrite/`.
- [x] Provide troubleshooting steps for `agy` detection and permission errors.

### 4. Technical Context / Notes
* **Affected Areas:** `USAGE.md`.
* **Suggested Approach / Architectural Hints:** Detail `swift build`, `swift test`, and service installation scripts with copy-paste terminal snippets.
* **Blockers or Dependencies:** [003-core-cli-engine.md](file:///Users/korakot/dev/korewrite/tickets/003-core-cli-engine.md), [005-macos-services-context-menu-integration.md](file:///Users/korakot/dev/korewrite/tickets/005-macos-services-context-menu-integration.md).

### 5. Alternatives Considered
* Scattering instructions across README or commit messages, rejected in favor of dedicated `USAGE.md`.

### 6. Visuals & Logs (Optional)
* Terminal command walkthrough.
