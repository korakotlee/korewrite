## Context
KoRewrite relies on prompt instructions to guide the `agy` AI engine in fixing speech-to-text transcription artifacts, homophones, and grammatical mistakes while adjusting the tone of the rewritten text. To allow users full control and extensibility, prompt definitions are stored as plain Markdown (`*.md`) files inside the user configuration directory `~/.korewrite/`.

## Goals / Non-Goals

**Goals:**
- Provide high-quality bundled starter prompts (`system.md`, `polite.md`, `professional.md`, `casual.md`, `concise.md`) under a repository `templates/` directory.
- Establish a consistent convention where `system.md` defines universal transcription fixing instructions, and other `*.md` files define specific tone adjustments.
- Implement a setup/bootstrap procedure to initialize `~/.korewrite/` and copy bundled prompts safely.
- Ensure runtime dynamic discovery of all `*.md` style templates in `~/.korewrite/` without requiring restarts or rebuilds.

**Non-Goals:**
- Hardcoding prompts within source code strings or binaries.
- Complex remote synchronization or cloud storage of user prompts.
- Proprietary prompt file formats (standard Markdown is used exclusively).

## Decisions

### Decision 1: Separation of System Instructions and Tone Styles
- **Choice**: Store core transcription correction rules in `system.md` and tone-specific directions in separate files (`polite.md`, `professional.md`, etc.).
- **Rationale**: Keeps style prompts concise and focused while guaranteeing consistent transcription cleanup regardless of the chosen style.
- **Alternatives Considered**: Combining system instructions into every style file, rejected due to duplication and maintenance burden.

### Decision 2: Plain Markdown Files for Template Storage
- **Choice**: Use standard UTF-8 `.md` files without required frontmatter.
- **Rationale**: Allows users to view and edit templates using standard text editors, Obsidian, or VS Code.
- **Alternatives Considered**: JSON/YAML configuration formats, rejected because multi-line prompt editing in JSON/YAML is cumbersome and error-prone.

### Decision 3: Safe Initialization and Seeding Strategy
- **Choice**: Setup logic creates `~/.korewrite/` if missing and copies default templates only if target files do not already exist (unless a `--force` flag is specified).
- **Rationale**: Prevents accidental loss of user modifications during updates or re-initializations.

### Decision 4: File Name Based Style Identifier Resolution
- **Choice**: The style name exposed to UI/CLI is derived from the filename without the `.md` extension (e.g., `professional.md` -> `professional` / `Professional`).
- **Rationale**: Simple, deterministic, and requires no metadata parsing.

## Risks / Trade-offs

- **[Missing User Config Directory or Templates]** → Fallback to reading bundled templates if `~/.korewrite/` is not yet initialized or missing `system.md`.
- **[Invalid File Types or Empty Files in Directory]** → Filter discovery strictly to `.md` files and ignore hidden/empty files.
