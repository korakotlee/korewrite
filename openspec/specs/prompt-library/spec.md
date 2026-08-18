# prompt-library Specification

## Purpose
Define the starter prompt templates, global speech-to-text repair instructions, configuration directory initialization, and dynamic runtime prompt discovery for KoRewrite.
## Requirements
### Requirement: Bundled Default Prompt Templates
The project SHALL provide a starter set of markdown prompt templates located under `templates/`, comprising a global `system.md` and tone-specific style templates (`polite.md`, `professional.md`, `casual.md`, and `concise.md`).

#### Scenario: Global system prompt content
- **WHEN** the `system.md` template is loaded
- **THEN** it SHALL contain instructions to correct speech-to-text transcription artifacts, phonetic slips, homophones, typos, and punctuation errors while strictly preserving the speaker's original intent.

#### Scenario: Tone style prompt contents
- **WHEN** tone style templates are loaded (`polite.md`, `professional.md`, `casual.md`, `concise.md`)
- **THEN** each template SHALL contain clear, targeted directives defining the desired tone and styling characteristics for rewritten output.

### Requirement: User Directory Initialization and Seeding
The system SHALL provide a bootstrap mechanism to initialize the `~/.korewrite/` configuration directory and copy default prompt templates when setting up the environment.

#### Scenario: Initial setup bootstrapping
- **WHEN** the template setup/initialization process runs and `~/.korewrite/` does not contain the default templates
- **THEN** the system SHALL create `~/.korewrite/` and copy `system.md`, `polite.md`, `professional.md`, `casual.md`, and `concise.md` into `~/.korewrite/`.

#### Scenario: Safe provisioning without overwriting custom edits
- **WHEN** a template already exists in `~/.korewrite/`
- **THEN** the setup process SHALL NOT overwrite the existing file unless explicitly instructed by a force flag.

### Requirement: Dynamic Runtime Template Discovery
The prompt loader SHALL dynamically discover and load all `*.md` files in the user configuration directory `~/.korewrite/` at runtime, recognizing `system.md` as the global system instructions and other `*.md` files as individual selectable rewrite styles, extracting display names from optional YAML frontmatter.

#### Scenario: Listing available rewrite styles with frontmatter metadata
- **WHEN** the system scans `~/.korewrite/` for rewrite styles
- **THEN** it SHALL return all markdown files (excluding `system.md`) as selectable style choices, resolving display names from `name:` or `displayName:` YAML frontmatter if present, falling back to title-cased filenames if absent.

#### Scenario: Dynamically adding a custom style
- **WHEN** a user creates a new markdown file in `~/.korewrite/` (e.g., `thai-formal.md`)
- **THEN** the system SHALL discover and make the new style immediately available without requiring recompilation or restart.

### Requirement: Prompt Frontmatter Stripping
The prompt loader SHALL strip YAML frontmatter enclosed by `---` delimiters when loading style prompts for AI rewrite generation, ensuring only the prompt instruction body is passed to the LLM.

#### Scenario: Style template with YAML frontmatter is loaded for rewrite
- **WHEN** a rewrite operation loads a style template containing YAML frontmatter metadata
- **THEN** the prompt builder receives only the prompt body instructions with the frontmatter removed.

