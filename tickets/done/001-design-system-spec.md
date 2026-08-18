**Type:** [x] UI / UX

---

### 1. Summary
Define the visual design system, token definitions, and UI specifications for KoRewrite in `DESIGN.md`.

### 2. Context & Problem
* **Current Behavior:** `DESIGN.md` is currently empty with no established styling guidelines or component layout standards.
* **Expected Behavior:** `DESIGN.md` contains a comprehensive design system covering the preview HUD, color palette, diff visualization tokens, typography, and interaction states.

### 3. Proposed Solution / Acceptance Criteria
- [x] Document color palettes including background, border, text, and diff highlights (additions/deletions) for both light and dark modes.
- [x] Define typography rules using standard macOS system fonts (SF Pro) and monospace code styling.
- [x] Detail the floating confirmation HUD modal layout, button placements (`[Apply]` / `[Cancel]`), and keybindings (`Enter` / `Esc`).
- [x] Specify micro-animations for window presentation and focus transitions.
- [x] Document error states and disabled indicator styles when `agy` is unreachable.

### 4. Technical Context / Notes
* **Affected Areas:** `DESIGN.md`, preview HUD components.
* **Suggested Approach / Architectural Hints:** Follow modern macOS design aesthetics with subtle blur/translucency (vibrancy), rounded corners, and clear visual hierarchy.
* **Blockers or Dependencies:** None.

### 5. Alternatives Considered
* Hardcoding styles directly in implementation code without a central design document, rejected to prevent visual drift.

### 6. Visuals & Logs (Optional)
* ASCII/Mermaid mockups of the floating diff preview modal.
