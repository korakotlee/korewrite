**Type:** [x] Backend / Performance

---

### 1. Summary
Implement the core CLI pipeline and `agy` executor using Test-Driven Development (TDD).

### 2. Context & Problem
* **Current Behavior:** There is no execution engine to assemble prompt templates, check `agy` availability, run the AI model command, and return rewritten text.
* **Expected Behavior:** A tested core engine loads markdown style files, builds unified prompts with `system.md`, executes `agy`, handles errors, and returns cleaned output.

### 3. Proposed Solution / Acceptance Criteria
- [ ] Implement unit tests first (using `swift test`) for prompt composition, template discovery, and CLI execution.
- [ ] Implement prompt builder combining `system.md`, selected style template, and the raw input text.
- [ ] Implement `agy` runner with timeout management and availability health checks.
- [ ] Gracefully handle missing `agy` binary or CLI failures with structured error returns.
- [ ] Provide a CLI entry point for command-line testing (`korewrite --style polite --text "..."`).

### 4. Technical Context / Notes
* **Affected Areas:** Core CLI module, tests directory.
* **Suggested Approach / Architectural Hints:** Build with pure Swift (Swift Package Manager) with XCTest / swift-testing suite and zero external runtime dependencies.
* **Blockers or Dependencies:** [002-sample-prompts-library.md](file:///Users/korakot/dev/korewrite/tickets/002-sample-prompts-library.md).

### 5. Alternatives Considered
* Direct HTTP calls to AI APIs, rejected because KoRewrite uses the local `agy` binary for seamless local integration.

### 6. Visuals & Logs (Optional)
* Test run outputs and CLI invocation logs.
