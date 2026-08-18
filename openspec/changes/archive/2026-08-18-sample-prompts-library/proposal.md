# Proposal: Sample Prompts Library

## Why
KoRewrite requires default prompt templates to transform speech-to-text transcription errors, phonetic slips, and punctuation issues into polished text across different writing tones. Users also need a structured, customizable local template directory (`~/.korewrite/`) that loads dynamically at runtime without recompiling or restarting.

## What Changes
- Add bundled starter prompt templates under `templates/`:
  - `templates/system.md`: Global instructions for repairing transcription artifacts, homophones, typos, and punctuation while preserving original meaning.
  - `templates/polite.md`: Courteous, respectful, and considerate tone adjustment.
  - `templates/professional.md`: Formal, workplace-appropriate tone for business emails and documentation.
  - `templates/casual.md`: Conversational, friendly, and approachable messaging.
  - `templates/concise.md`: Direct, clear, high-signal brevity eliminating fluff.
- Establish template provisioning logic to seed or initialize default templates into the user's configuration directory (`~/.korewrite/`).
- Define template dynamic discovery and loading mechanisms so custom `*.md` style templates placed in `~/.korewrite/` are recognized automatically.

## Capabilities

### New Capabilities
- `prompt-library`: Default bundled prompt templates, system instructions for transcription correction, and dynamic runtime template loading from user configuration directory.

### Modified Capabilities
<!-- None -->

## Impact
- **Files & Assets**: Adds `templates/` containing default markdown prompt files.
- **Configuration & Runtime**: Establishes schema and expectations for `~/.korewrite/*.md` dynamic discovery.
- **Dependencies**: No external runtime dependencies; purely plain text markdown prompts read by KoRewrite engine.
