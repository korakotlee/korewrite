# core-engine Specification

## Purpose
Define the core prompt composition pipeline, AI executable discovery, subprocess execution with timeout and error handling, and the command-line interface for KoRewrite.
## Requirements
### Requirement: Unified Prompt Composition
The engine SHALL provide a `PromptBuilder` that combines the system prompt instructions from `system.md`, the selected style template instructions, and the raw input text into a single cohesive prompt payload.

#### Scenario: Composing prompt with valid system and style templates
- **WHEN** the prompt builder is invoked with a system template, a style template (e.g., `polite`), and user input text
- **THEN** it SHALL return a formatted prompt containing the system instructions, the style guidelines, and the input text clearly delimited.

#### Scenario: Handling missing or empty input text
- **WHEN** the prompt builder receives empty or whitespace-only input text
- **THEN** it SHALL return an empty result or error without invoking the AI executable.

### Requirement: Executable Discovery and Health Check
The engine SHALL discover the `agy` binary location across standard system search paths and verify whether the executable is installed and runnable.

#### Scenario: Checking executable availability when present
- **WHEN** `agy` is located in the user PATH or standard binary paths (such as `/usr/local/bin`, `/opt/homebrew/bin`, or `~/.gemini/antigravity-ide/bin`)
- **THEN** the availability check SHALL return success with the resolved binary path.

#### Scenario: Checking executable availability when missing
- **WHEN** `agy` cannot be found in any search path
- **THEN** the availability check SHALL return a descriptive `binaryNotFound` status indicating that `agy` is unavailable.

### Requirement: Process Execution with Timeout Management
The engine SHALL execute the AI CLI process asynchronously or synchronously with a configurable execution timeout, capturing standard output and standard error.

#### Scenario: Successful command execution
- **WHEN** the AI runner executes `agy` with the prompt payload within the configured timeout limit
- **THEN** it SHALL return the trimmed standard output containing the rewritten text.

#### Scenario: Process execution exceeding timeout
- **WHEN** the `agy` process does not finish within the specified timeout duration
- **THEN** the engine SHALL terminate the spawned subprocess and throw an `executionTimeout` error.

#### Scenario: Non-zero process exit
- **WHEN** the `agy` process fails with a non-zero exit code
- **THEN** the engine SHALL capture the standard error output and return an `executionFailed` error with the error message.

### Requirement: Structured Error Handling
The engine SHALL define a structured `KoRewriteError` error enumeration covering all operational failure states.

#### Scenario: Requesting a non-existent style
- **WHEN** the user requests a style name that does not exist in `~/.korewrite/`
- **THEN** the engine SHALL throw a `styleNotFound` error specifying the missing style name and available alternatives.

### Requirement: Command-Line Interface (CLI)
The project SHALL provide a standalone executable `korewrite` that allows users to invoke rewriting from the terminal or scripts.

#### Scenario: Running rewrite via argument text
- **WHEN** running `korewrite --style <name> --text "<text>"`
- **THEN** it SHALL execute the rewrite pipeline and print the result to stdout.

#### Scenario: Running rewrite via piped standard input
- **WHEN** piping text into `korewrite --style <name>`
- **THEN** it SHALL read text from stdin, execute the pipeline, and output the rewritten content to stdout.

#### Scenario: Listing available styles via CLI
- **WHEN** running `korewrite --list-styles`
- **THEN** it SHALL list all discoverable rewrite styles from the templates directory.

