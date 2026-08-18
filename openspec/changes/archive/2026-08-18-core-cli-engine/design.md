## Context

KoRewrite provides in-place text rewriting and tone adjustment for macOS.
The core engine is responsible for assembling prompts from system and style templates, executing the local `agy` command-line process, enforcing execution timeouts, and delivering clean rewritten text back to calling layers (such as the CLI or the floating HUD).
To support Test-Driven Development (TDD), the engine must be decoupled from the actual system process execution via protocols and dependency injection.

## Goals / Non-Goals

**Goals:**
- Provide a robust `PromptBuilder` that combines global `system.md`, style prompts, and input text into a unified instruction payload.
- Implement an `AgyRunner` backed by a `ProcessRunnerProtocol` to enable deterministic unit testing and mock subprocess execution.
- Implement binary discovery logic to find `agy` across standard system paths (`PATH`, `/usr/local/bin`, `/opt/homebrew/bin`, `~/.gemini/antigravity-ide/bin`).
- Enforce execution timeouts with proper subprocess termination.
- Provide structured error reporting via `KoRewriteError`.
- Provide a responsive `korewrite` CLI tool supporting arguments and standard input pipes.

**Non-Goals:**
- Floating HUD UI / AppKit panels (covered in a separate UI change).
- macOS Services / Quick Action installer integration.
- Direct network calls to remote AI APIs.

## Decisions

### 1. Protocol-Driven Process Execution
We define `ProcessRunnerProtocol` and `SystemProcessRunner` to wrap macOS `Foundation.Process`.
In tests, `MockProcessRunner` allows simulating immediate success, timeout delays, non-zero exits, or missing executables without depending on a live `agy` install.

`AgyRunner` will invoke the CLI with:
`agy -p "<prompt>" --disable-slash-commands --output-format text`
Passing `--disable-slash-commands` prevents accidental slash command / skill expansions when processing user input text.

*Alternatives Considered:*
- Executing `Process` directly inside `AgyRunner`: Rejected because unit tests would either require live `agy` or be impossible to run in isolated CI environments.

### 2. Zero External Dependencies
The CLI arguments and core engine use pure Swift standard library and Foundation.
Argument parsing is implemented directly in `Sources/KoRewriteCLI/` to avoid adding external package dependencies such as `swift-argument-parser`.

*Alternatives Considered:*
- Adding `apple/swift-argument-parser`: Rejected to keep the build light, fast, and completely standalone.

### 3. Unified Error Type (`KoRewriteError`)
All engine failures (missing templates, missing binary, execution timeout, process failure) conform to `LocalizedError` and `CustomStringConvertible`.
This ensures clear diagnostics for both CLI stdout/stderr and UI alert displays.

### 4. Non-Blocking Pipe Reading
When invoking subprocesses, output pipes are read asynchronously before calling `waitUntilExit()` to avoid deadlocks on large stdout/stderr buffers.

## Risks / Trade-offs

- [Risk] Subprocess hangs if `agy` blocks indefinitely.
  → Mitigation: `AgyRunner` schedules a timeout handler that terminates the child process and closes pipes after the configured deadline.
- [Risk] Binary location may differ across user shells and PATH configurations.
  → Mitigation: Discovery searches common PATH entries, Homebrew paths, and Gemini directory paths in addition to the runtime environment PATH.
- [Risk] Piping multiline stdin with different newline encodings.
  → Mitigation: Standardized UTF-8 reading with newline normalization before passing to prompt builder.
