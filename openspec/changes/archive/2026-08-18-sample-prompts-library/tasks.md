## 1. Bundled Prompt Templates Creation

- [x] 1.1 Create `templates/system.md` containing global transcription error correction rules (homophones, typos, speech-to-text slips, punctuation, and intent preservation)
- [x] 1.2 Create `templates/polite.md` defining courteous and considerate tone adjustments
- [x] 1.3 Create `templates/professional.md` defining formal workplace tone for emails and documentation
- [x] 1.4 Create `templates/casual.md` defining conversational, friendly tone
- [x] 1.5 Create `templates/concise.md` defining direct, high-signal brevity

## 2. Template Seeding and Discovery Logic

- [x] 2.1 Implement template bootstrapping utility to initialize `~/.korewrite/` and safely copy default templates when missing
- [x] 2.2 Implement template discovery helper to dynamically list and load `system.md` and all custom `*.md` style templates from `~/.korewrite/` with fallback to bundled templates

## 3. Verification & Testing

- [x] 3.1 Validate template contents for formatting, clarity, and token efficiency
- [x] 3.2 Add automated tests for template bootstrapping, safe non-overwrite behavior, and dynamic runtime discovery
