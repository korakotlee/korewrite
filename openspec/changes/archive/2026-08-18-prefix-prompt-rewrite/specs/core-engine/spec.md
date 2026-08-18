## MODIFIED Requirements

### Requirement: Unified Prompt Composition
The engine SHALL provide a `PromptBuilder` that prepends the `/rewrite` slash command prefix and combines the system prompt instructions from `system.md`, the selected style template instructions, and the raw input text into a single cohesive prompt payload.

#### Scenario: Composing prompt with valid system and style templates
- **WHEN** the prompt builder is invoked with a system template, a style template (e.g., `polite`), and user input text
- **THEN** it SHALL return a formatted prompt starting with `/rewrite` followed by the system instructions, the style guidelines, and the input text clearly delimited.

#### Scenario: Handling missing or empty input text
- **WHEN** the prompt builder receives empty or whitespace-only input text
- **THEN** it SHALL return an empty result or error without invoking the AI executable.
