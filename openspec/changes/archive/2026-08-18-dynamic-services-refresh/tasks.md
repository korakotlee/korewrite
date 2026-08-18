## 1. Prompt Frontmatter Parsing & Stripping

- [x] 1.1 Implement YAML frontmatter parsing in `PromptTemplateManager` to extract `name:` or `displayName:` metadata (specs/prompt-library/spec.md#listing-available-rewrite-styles-with-frontmatter-metadata)
- [x] 1.2 Implement frontmatter stripping in `loadStylePrompt(named:)` to pass only prompt body instructions to the LLM (specs/prompt-library/spec.md#prompt-frontmatter-stripping)
- [x] 1.3 Add title-casing fallback for styles without frontmatter (e.g. `thai-official` -> `KoRewrite - Thai Official`) (specs/prompt-library/spec.md#listing-available-rewrite-styles-with-frontmatter-metadata)

## 2. Dynamic macOS Service Synchronization & Pruning

- [x] 2.1 Update `ServiceWorkflowGenerator` to dynamically resolve `ServiceDefinition`s from `PromptTemplateManager.listStyles()` and frontmatter metadata (specs/macos-services/spec.md#running-refresh-command)
- [x] 2.2 Implement orphan workflow pruning to remove obsolete `KoRewrite - *.workflow` bundles from `~/Library/Services/` (specs/macos-services/spec.md#orphan-workflow-cleanup)
- [x] 2.3 Implement `syncServices()` combining dynamic generation, orphan pruning, and `/System/Library/CoreServices/pbs -flush` cache flushing (specs/macos-services/spec.md#pasteboard-service-cache-flush)

## 3. CLI Integration

- [x] 3.1 Add `--refresh` and `refresh` flags/commands to `KoRewriteCLI` in `Sources/KoRewriteCLI/main.swift` (specs/macos-services/spec.md#running-refresh-command)
- [x] 3.2 Update CLI usage and help text (`printUsage()`) with `--refresh` (specs/macos-services/spec.md#running-refresh-command)

## 4. Testing & Validation

- [x] 4.1 Add unit tests in `PromptTemplateManagerTests` verifying frontmatter extraction, body stripping, and fallback title generation (specs/prompt-library/spec.md#listing-available-rewrite-styles-with-frontmatter-metadata)
- [x] 4.2 Add unit tests in `ServiceWorkflowGeneratorTests` verifying dynamic discovery, workflow generation, and orphan workflow pruning (specs/macos-services/spec.md#orphan-workflow-cleanup)
- [x] 4.3 Run `swift test` to ensure all unit tests pass cleanly

## 5. Documentation

- [x] 5.1 Update `README.md` and `USAGE.md` with `--refresh` command examples and YAML frontmatter documentation (specs/macos-services/spec.md#running-refresh-command)
