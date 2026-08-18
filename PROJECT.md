# KoRewrite - Native macOS In-Place AI Rewriting & Tone Polishing

## Problem Statement
How might we enable macOS users to instantly fix speech-to-text transcription errors, repair grammatical mistakes, and restyle selected text across any application via a native right-click workflow with a quick confirmation preview?

## Recommended Direction
**Native macOS Quick Action / Service + Lightweight Menu Bar / Swift Floating HUD**

1. **Trigger & Selection:**
   A native macOS Service (`.workflow` / Quick Action) appears directly in the system context menu under Services / Quick Actions when text is selected.
   Selecting a rewrite style (or triggering a shortcut) grabs the active selection.

2. **Prompt Composition & Engine Execution:**
   The backend scans `~/.korewrite/` for prompt templates (`*.md`) alongside a global `system.md`.
   It constructs a unified prompt instructing `agy` to preserve the core intent while fixing speech-to-text phonetic slips and applying the target tone.
   The request executes via the local `agy` CLI binary.

3. **Preview & Diff Confirmation HUD:**
   Instead of blind overwriting, a minimal, native floating popup / HUD displays the original text, the proposed rewrite, and a visual diff.
   Pressing `Enter` (or clicking Apply) replaces the original selected text in-place using macOS Accessibility API or simulated paste (`Cmd+V`).
   Pressing `Esc` cancels without touching the document.

4. **Extensibility & Configuration:**
   Style prompts remain simple, human-editable markdown files in `~/.korewrite/` (e.g., `polite.md`, `professional.md`, `casual.md`, `thai-formal.md`).
   Dynamic reloading ensures users can add or tweak styles on the fly without recompiling or restarting.

## Key Assumptions to Validate
- [ ] **Accessibility / Paste Reliability:** Test whether simulated keystrokes or Accessibility APIs reliably replace active selections across diverse apps (Chrome, Slack, VS Code, Notes, Word).
- [ ] **CLI Execution Latency:** Verify that invoking `agy` with system and style prompts returns within acceptable interactive latency (< 2-3 seconds).
- [ ] **Native Services Discovery:** Confirm macOS Services automatically list dynamically populated styles or if a unified picker HUD invoked by a single service is faster and cleaner.
- [ ] **Text Selection Capture:** Ensure multi-line selections and rich-text inputs retain basic formatting or fall back cleanly to plain text.

## MVP Scope
- **Core CLI Wrapper & Pipeline:**
  A lightweight executable (`korewrite`) that loads `~/.korewrite/*.md`, calls `agy`, and handles standard input/output.
- **Default Prompt Library:**
  Pre-packaged `system.md`, `polite.md`, `professional.md`, `casual.md`, and `concise.md` in `~/.korewrite/`.
- **macOS Quick Action / Service:**
  Standard macOS Quick Action / Service wrapper to capture highlighted text from any application.
- **Diff & Confirm Popup:**
  A lightweight native modal / floating dialog (Swift / Webview / osascript dialog) showing the diff with `[Apply]` (`Enter`) and `[Cancel]` (`Esc`).
- **In-Place Text Replacement:**
  Automated clipboard swap and `Cmd+V` dispatch with clipboard restoration.

## Not Doing (and Why)
- **Real-time Live Audio Transcription:**
  We rely on macOS built-in Dictation or Whisper tools.
  KoRewrite is purely a post-processing text intelligence layer.
- **Cloud Backend / Remote Account Sync:**
  All operations run strictly through local `agy` and local config files for privacy and zero cloud dependency.
- **Complex Rich-Text WYSIWYG Formatting Preservation:**
  Speech-to-text output is predominantly plain text.
  Preserving complex HTML/RTF structures adds massive fragility across varied macOS text engines.
- **Heavy Electron Wrapper App:**
  Avoid large memory footprint.
  Keep it as a lightweight native Swift or shell/python daemon with minimal resource consumption.

## Open Questions
- Should each `*.md` file represent a separate entry in the macOS Context Menu (Services), or should a single "KoRewrite..." Service open a fast search/picker HUD? 
  (A single service with a fuzzy picker scales better when users have 15+ styles). I'm thinking each style is gonna be a sub-menu from the context menu and I expect to have not too much styles like maybe 5-6 styles
- Do we need a fallback notification if `agy` fails or is offline? If agy is not available then the context_menu should show disabled KoRewrite

## Implementation
- Test first development
- UI first. Put installation instruction to build from code in to @USAGE.md so I can test run along with coding.
- Put design system in @DESIGN.md so we maintain consistent UI
- Create a sample prompts: `system.md`, `polite.md`, `professional.md`, `casual.md`, and `concise.md`