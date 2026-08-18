**Type:** [x] Feature Request

---

### 1. Summary
Add a `--refresh` command to dynamically synchronize installed macOS Services in `~/Library/Services/` with prompt templates in `~/.korewrite/`.

### 2. Context & Problem
* **Current Behavior:** `ServiceWorkflowGenerator` installs a static, hard-coded list of 7 default styles (`ServiceWorkflowGenerator.defaultServices`). When users add, edit, or delete markdown style templates in `~/.korewrite/`, the Services context menu remains unchanged and does not reflect custom or modified styles.
* **Expected Behavior:** `~/.korewrite/` acts as the single source of truth for available styles. Running `korewrite --refresh` (or updating/reinstalling services) inspects `~/.korewrite/`, removes orphan `.workflow` bundles for deleted styles, generates/updates `.workflow` bundles for active styles, and flushes the macOS pasteboard service cache (`pbs -flush`).

### 3. Proposed Solution / Acceptance Criteria
- [ ] Add `--refresh` (and `refresh`) CLI flag to `KoRewriteCLI`.
- [ ] Add frontmatter parser in `PromptTemplateManager` / `ServiceWorkflowGenerator` to extract display name (e.g. `name: KoRewrite - Casual` or `displayName: KoRewrite - Casual`) with a graceful fallback to title-cased filename if frontmatter is absent.
- [ ] Ensure prompt loader strips YAML frontmatter before passing style instructions to the LLM prompt builder.
- [ ] Update `ServiceWorkflowGenerator` to dynamically discover styles from `PromptTemplateManager.listStyles()` and read display names from frontmatter rather than relying on a hardcoded list.
- [ ] Clean up orphan `KoRewrite - *.workflow` bundles in `~/Library/Services/` that no longer have a corresponding `.md` template in `~/.korewrite/`.
- [ ] Regenerate/update `.workflow` bundles for all current styles in `~/.korewrite/`.
- [ ] Trigger `/System/Library/CoreServices/pbs -flush` after synchronization to immediately update the macOS context menu.
- [ ] Add unit tests in `KoRewriteTests` verifying frontmatter parsing, dynamic style discovery, bundle generation, and orphan workflow cleanup.
- [ ] Update [README.md](file:///Users/korakot/dev/korewrite/README.md) and [USAGE.md](file:///Users/korakot/dev/korewrite/USAGE.md) documentation with the new `--refresh` command and frontmatter format.

### 4. Technical Context / Notes
* **Affected Areas:** CLI (`Sources/KoRewriteCLI/main.swift`), Service Generator (`Sources/KoRewriteCore/Service/ServiceWorkflowGenerator.swift`), Template Manager (`Sources/KoRewriteCore/PromptTemplateManager.swift`), Bundled Templates (`Sources/KoRewriteCore/BundledTemplates.swift`).
* **Suggested Approach / Architectural Hints:**
  - Parse YAML frontmatter between `---` delimiters to extract `name:` or `displayName:` property.
  - Body prompt parsing helper: Return prompt content with frontmatter stripped when loading style prompts for text generation.
  - Scan `~/Library/Services/KoRewrite - *.workflow` to detect files that no longer match active styles and remove them via `FileManager`.
  - Ensure `installServices()` and `refreshServices()` default to scanning `PromptTemplateManager().listStyles()`.
* **Blockers or Dependencies:** None.

### 5. Alternatives Considered
* **Watching directory with `FSEvents`:** Auto-refreshing in the background via a daemon would require a persistent background process. Explicit CLI invocation (`korewrite --refresh`) keeps the tool lightweight and deterministic without running background daemons.

### 6. Visuals & Logs (Optional)
* Right-click Services menu updating dynamically to reflect newly added or removed styles from `~/.korewrite/`.
