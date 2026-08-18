## Why

KoRewrite currently lacks an execution pipeline to compose system and style prompts, check the availability of the local `agy` executable, invoke the model process with timeouts, and return rewritten text.
Implementing this core engine enables in-place rewriting across applications and provides a command-line interface for automated testing and user execution.

## What Changes

- Implement a prompt builder (`PromptBuilder`) that unifies `system.md`, chosen tone templates from `~/.korewrite/`, and input text.
- Implement an `agy` process executor (`AgyRunner`) with binary location discovery, health/availability checks, and execution timeout handling.
- Define structured error types (`KoRewriteError`) for missing binaries, invalid templates, execution timeouts, and non-zero exit codes.
- Implement the `korewrite` command-line executable entry point supporting `--style`, `--text`, standard input piping, and listing available styles.
- Add comprehensive unit and integration tests using `swift test` covering prompt assembly, mock/real runner flows, and error handling.

## Capabilities

### New Capabilities
- `core-engine`: Core prompt assembly, `agy` process execution, error diagnostics, and CLI invocation interface.

### Modified Capabilities
<!-- None -->

## Impact

- **Swift Targets**: Adds engine and runner logic in `Sources/KoRewriteCore/` and CLI argument parsing in `Sources/KoRewriteCLI/`.
- **Tests**: Adds unit test suites under `Tests/KoRewriteCoreTests/`.
- **Dependencies**: Uses pure Swift Foundation and standard library without external third-party dependencies.
