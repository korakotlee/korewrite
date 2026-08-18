## Context

`KoRewrite` integrates with macOS Quick Actions via `.workflow` bundles in `~/Library/Services/`. In the initial implementation, `ServiceWorkflowGenerator` used a hardcoded static array of 7 default services. When users customized templates in `~/.korewrite/` (e.g. adding new styles or deleting existing ones), the installed Services did not reflect these changes. Furthermore, there was no standard way to declare custom display names for Services in markdown templates or synchronize the Services menu dynamically.

## Goals / Non-Goals

**Goals:**
- Add YAML frontmatter parsing to `PromptTemplateManager` to extract `name:` or `displayName:` metadata while gracefully stripping it when serving the prompt body to the LLM.
- Fallback gracefully to title-cased filenames (e.g., `thai-official` -> `KoRewrite - Thai Official`) when frontmatter is absent.
- Update `ServiceWorkflowGenerator` to dynamically discover styles via `PromptTemplateManager.listStyles()` and generate `.workflow` bundles using extracted display names.
- Provide a prune/cleanup mechanism for obsolete `KoRewrite - *.workflow` bundles whose backing style template no longer exists.
- Add `--refresh` and `refresh` CLI commands to trigger dynamic synchronization and execute `/System/Library/CoreServices/pbs -flush`.
- Maintain full backwards compatibility for `installServices()` and existing style files without frontmatter.

**Non-Goals:**
- Running a persistent daemon or file watcher with `FSEvents` (manual CLI command `korewrite --refresh` is explicit, lightweight, and deterministic).
- Modifying non-KoRewrite workflows in `~/Library/Services/`.

## Decisions

### 1. Frontmatter Format & Parser
- **Format**: Simple YAML frontmatter enclosed by `---` at the start of `.md` files:
  ```markdown
  ---
  name: KoRewrite - Casual
  ---
  Make this text casual and friendly.
  ```
- **Supported Keys**: Check `name:` first, then `displayName:`.
- **Parsing Strategy**: Lightweight regex / line scanning without adding heavy external YAML dependencies to Swift Package Manager.
- **Prompt Stripping**: `loadStylePrompt` strips the frontmatter block, returning only the body. A dedicated method `loadStyleMetadata` (or `getDisplayName(for:)`) inspects the raw file for frontmatter.

### 2. Dynamic Discovery & Orphan Pruning
- `ServiceWorkflowGenerator.syncServices(from:templateManager:customServicesDirectory:customBinaryPath:)`:
  1. Enumerate active styles from `PromptTemplateManager.listStyles()`.
  2. Map each style to `ServiceDefinition` with its resolved display name and workflow bundle name.
  3. Scan destination directory (`~/Library/Services/`) for existing `KoRewrite - *.workflow` directories.
  4. Compare existing workflow bundles against the target active workflow set; delete any obsolete KoRewrite workflow bundles via `fileManager.removeItem(at:)`.
  5. Write/update active workflow bundles.
  6. Execute `pbs -flush`.

### 3. CLI Command
- Support both `korewrite --refresh` and `korewrite refresh` in `KoRewriteCLI`.
- Update usage output and help flags.

## Risks / Trade-offs

- **[Risk] Unintended deletion of user services** → **Mitigation**: Only prune workflows strictly matching the prefix `KoRewrite - ` and suffix `.workflow` within the target services directory, and only if they do not match any currently active style's workflow name.
- **[Risk] `pbs -flush` failure on non-standard macOS environments** → **Mitigation**: Safely execute `pbs -flush` via `Process`, ignoring errors gracefully if the executable is not found or fails in CI/headless test environments.
