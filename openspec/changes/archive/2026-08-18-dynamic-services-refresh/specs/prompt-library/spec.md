## MODIFIED Requirements

### Requirement: Dynamic Runtime Template Discovery
The prompt loader SHALL dynamically discover and load all `*.md` files in the user configuration directory `~/.korewrite/` at runtime, recognizing `system.md` as the global system instructions and other `*.md` files as individual selectable rewrite styles, extracting display names from optional YAML frontmatter.

#### Scenario: Listing available rewrite styles with frontmatter metadata
- **WHEN** the system scans `~/.korewrite/` for rewrite styles
- **THEN** it SHALL return all markdown files (excluding `system.md`) as selectable style choices, resolving display names from `name:` or `displayName:` YAML frontmatter if present, falling back to title-cased filenames if absent.

#### Scenario: Dynamically adding a custom style
- **WHEN** a user creates a new markdown file in `~/.korewrite/` (e.g., `thai-formal.md`)
- **THEN** the system SHALL discover and make the new style immediately available without requiring recompilation or restart.

## ADDED Requirements

### Requirement: Prompt Frontmatter Stripping
The prompt loader SHALL strip YAML frontmatter enclosed by `---` delimiters when loading style prompts for AI rewrite generation, ensuring only the prompt instruction body is passed to the LLM.

#### Scenario: Style template with YAML frontmatter is loaded for rewrite
- **WHEN** a rewrite operation loads a style template containing YAML frontmatter metadata
- **THEN** the prompt builder receives only the prompt body instructions with the frontmatter removed.
