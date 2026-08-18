## 1. Test Suite and Core Interfaces (TDD First)

- [x] 1.1 Define `KoRewriteError` enum and localized error descriptions
- [x] 1.2 Define `ProcessRunnerProtocol` and `MockProcessRunner` for test isolation
- [x] 1.3 Write unit tests for `PromptBuilder` in `Tests/KoRewriteCoreTests/PromptBuilderTests.swift`
- [x] 1.4 Write unit tests for `AgyRunner` (verifying `-p` / `--print`, `--disable-slash-commands`, timeout, exit failure, binary discovery)

## 2. Core Engine Implementation

- [x] 2.1 Implement `PromptBuilder` to combine system instructions, style templates, and input text
- [x] 2.2 Implement `BinaryLocator` to discover the `agy` binary in user and system paths
- [x] 2.3 Implement `SystemProcessRunner` with non-blocking pipe reading and timeout termination
- [x] 2.4 Implement `AgyRunner` to invoke `agy -p "<prompt>" --disable-slash-commands --output-format text`
- [x] 2.5 Run `swift test` to verify all core engine tests pass cleanly

## 3. CLI Interface Implementation

- [x] 3.1 Implement argument parsing in `Sources/KoRewriteCLI/` for `--style`, `--text`, `--list-styles`, `--timeout`, and `--help`
- [x] 3.2 Implement stdin streaming support to read piped input when `--text` is omitted
- [x] 3.3 Wire `KoRewriteCLI` to `AgyRunner` and `PromptTemplateManager` with structured exit codes and error output
- [x] 3.4 Validate `swift build` and end-to-end CLI execution
