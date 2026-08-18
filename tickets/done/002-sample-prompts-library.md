**Type:** [x] Feature Request

---

### 1. Summary
Create the sample prompt library files (`system.md`, `polite.md`, `professional.md`, `casual.md`, `concise.md`) and default template setup logic.

### 2. Context & Problem
* **Current Behavior:** No prompt templates exist in the project, and `~/.korewrite/` configuration directory structure is not established.
* **Expected Behavior:** KoRewrite supplies bundled starter prompts for speech-to-text post-processing and tone adjustments, with automated initial copying to `~/.korewrite/`.

### 3. Proposed Solution / Acceptance Criteria
- [x] Create `templates/system.md` containing global instructions to fix speech-to-text artifacts, homophones, typos, and punctuation errors.
- [x] Create `templates/polite.md` for courteous, considerate communication.
- [x] Create `templates/professional.md` for formal workplace email and documentation.
- [x] Create `templates/casual.md` for conversational, friendly messaging.
- [x] Create `templates/concise.md` for direct, high-signal brevity.
- [x] Ensure prompt loader dynamically reads `~/.korewrite/*.md` at runtime so users can add custom styles.

### 4. Technical Context / Notes
* **Affected Areas:** `templates/`, configuration loader module.
* **Suggested Approach / Architectural Hints:** Package sample prompts in a repository folder `templates/` and provide a bootstrap command to install them into `~/.korewrite/`.
* **Blockers or Dependencies:** None.

### 5. Alternatives Considered
* Hardcoding prompts in code strings, rejected because users need to edit and create Markdown prompt files easily.

### 6. Visuals & Logs (Optional)
* Example prompt structure and variables passed to `agy`.
