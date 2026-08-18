**Type:** [x] UI / UX

---

### 1. Summary
Build the floating diff preview and confirmation HUD modal according to the design system.

### 2. Context & Problem
* **Current Behavior:** No preview interface exists to let users review and approve AI rewrites before replacing text in their active app.
* **Expected Behavior:** A lightweight native floating window appears showing side-by-side or inline diffs, supporting instant keyboard confirmation (`Enter` to apply, `Esc` to cancel).

### 3. Proposed Solution / Acceptance Criteria
- [ ] Build a floating HUD window adhering to `DESIGN.md` styling and vibrancy.
- [ ] Render clear visual diff highlighting differences between original speech-to-text input and generated rewrite.
- [ ] Support keyboard shortcuts: `Enter` triggers apply callback, `Esc` dismisses without changes.
- [ ] Display an animated loading spinner or pulse state while awaiting CLI output.
- [ ] Provide clear error feedback or disabled banner if `agy` fails or is not found.

### 4. Technical Context / Notes
* **Affected Areas:** UI modal component, HUD presenter.
* **Suggested Approach / Architectural Hints:** Native SwiftUI / AppKit floating panel (`NSPanel` with `.nonactivatingPanel` level) or lightweight Webview HUD for rapid iteration.
* **Blockers or Dependencies:** [001-design-system-spec.md](file:///Users/korakot/dev/korewrite/tickets/001-design-system-spec.md).

### 5. Alternatives Considered
* Immediate silent replacement without preview, rejected because speech-to-text corrections require user verification before overwriting text.

### 6. Visuals & Logs (Optional)
* Screenshot or video of HUD appearing over active applications.
