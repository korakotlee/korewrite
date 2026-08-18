**Type:** [x] External Integration

---

### 1. Summary
Implement native macOS Services and Quick Actions integration with in-place text replacement.

### 2. Context & Problem
* **Current Behavior:** Right-clicking selected text in macOS apps does not show KoRewrite style options, and there is no mechanism to replace active selections.
* **Expected Behavior:** Right-click context menu (Services / Quick Actions) shows KoRewrite sub-menu styles (5-6 styles), grabs selected text, invokes the HUD, and pastes the confirmed rewrite in-place.

### 3. Proposed Solution / Acceptance Criteria
- [ ] Create macOS Quick Action / Service definitions (.workflow or app extension) for available rewrite styles.
- [ ] Implement text selection capture from active frontmost application.
- [ ] Implement reliable in-place text replacement using clipboard swap and simulated paste (`Cmd+V`) with clipboard restoration.
- [ ] Disable or display graceful status when `agy` is not installed or unavailable.
- [ ] Verify functionality across major applications (Safari, Chrome, Slack, VS Code, Notes).

### 4. Technical Context / Notes
* **Affected Areas:** macOS Services, Automator workflow scripts, accessibility helper.
* **Suggested Approach / Architectural Hints:** Package native macOS Automator Quick Actions / `.workflow` service bundles that invoke the compiled Swift binary (`korewrite`) with the selected style parameter.
* **Blockers or Dependencies:** [003-core-cli-engine.md](file:///Users/korakot/dev/korewrite/tickets/003-core-cli-engine.md), [004-diff-preview-hud-ui.md](file:///Users/korakot/dev/korewrite/tickets/004-diff-preview-hud-ui.md).

### 5. Alternatives Considered
* Global keyboard hook daemon intercepting keystrokes directly, rejected in favor of native macOS Services context menu integration.

### 6. Visuals & Logs (Optional)
* Screenshot of right-click context menu showing KoRewrite styles.
