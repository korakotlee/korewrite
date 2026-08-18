## Why

Currently, `ServiceWorkflowGenerator` generates and installs a hardcoded, static list of macOS Services (`ServiceWorkflowGenerator.defaultServices`). When users customize, add, or remove style markdown files in `~/.korewrite/`, the macOS Quick Actions / Services context menu does not reflect those changes. Users need a dynamic synchronization mechanism (`korewrite --refresh`) that scans `~/.korewrite/`, extracts display names from YAML frontmatter, purges orphan workflows, installs/updates workflows for all active styles, and flushes the macOS pasteboard service cache (`pbs -flush`).

## What Changes

- Add `--refresh` (and `refresh` subcommand) to `KoRewriteCLI` to synchronize installed macOS Services with `~/.korewrite/` templates.
- Add YAML frontmatter support to prompt style templates in `PromptTemplateManager`, allowing custom display names via `name:` or `displayName:` metadata, falling back to title-cased filename if missing.
- Ensure prompt loading strips frontmatter so LLMs receive only the prompt body text.
- Update `ServiceWorkflowGenerator` to dynamically discover styles from `PromptTemplateManager.listStyles()` and resolve display names.
- Automatically prune orphaned `KoRewrite - *.workflow` bundles in `~/Library/Services/` that no longer correspond to active markdown templates in `~/.korewrite/`.
- Flush the macOS pasteboard service cache using `/System/Library/CoreServices/pbs -flush` after installation or refresh to immediately update macOS context menus.
- Update documentation (`README.md`, `USAGE.md`) and add comprehensive unit test coverage.

## Capabilities

### New Capabilities
<!-- No new standalone capabilities; this extends prompt-library and macos-services. -->

### Modified Capabilities
- `macos-services`: Add requirement for dynamic workflow synchronization, orphan workflow pruning, and pasteboard service cache flushing.
- `prompt-library`: Add requirement for YAML frontmatter parsing (extracting display names, stripping metadata from prompt body).

## Impact

- Affected files: `Sources/KoRewriteCLI/main.swift`, `Sources/KoRewriteCore/Service/ServiceWorkflowGenerator.swift`, `Sources/KoRewriteCore/PromptTemplateManager.swift`, `Sources/KoRewriteCore/BundledTemplates.swift`.
- Tests: `Tests/KoRewriteTests/ServiceWorkflowGeneratorTests.swift`, `Tests/KoRewriteTests/PromptTemplateManagerTests.swift`.
- Documentation: `README.md`, `USAGE.md`.
