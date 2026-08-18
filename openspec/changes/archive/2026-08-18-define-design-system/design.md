## Context

KoRewrite is a native macOS in-place text rewriting and tone-polishing tool that integrates seamlessly with macOS system context menus and Quick Actions. Prior to this change, `DESIGN.md` in the repository was an empty placeholder without established visual standards, color tokens, or UI component specifications. Establishing a comprehensive design specification ensures consistent visual quality across SwiftUI HUD components, menus, and diff previews.

## Goals / Non-Goals

**Goals:**
- Provide a single source of truth in `DESIGN.md` for UI tokens, typography, window layouts, diff highlights, and animation parameters.
- Ensure 100% adherence to macOS Human Interface Guidelines (HIG) with native vibrancy/materials for both Light and Dark modes.
- Specify exact layouts, component dimensions, and interaction behaviors for the floating diff confirmation HUD modal.
- Include structured Mermaid and ASCII diagrams illustrating HUD layouts and user interaction flows.

**Non-Goals:**
- Implementing the Swift/SwiftUI application code (implementation will be done during the apply phase according to tasks).
- Designing non-macOS cross-platform interfaces (KoRewrite is strictly native macOS).

## Decisions

### 1. Centralized Markdown Design Documentation (`DESIGN.md`)
- **Decision:** Document all tokens, color hex/system references, font definitions, and layout specs in root `DESIGN.md`.
- **Rationale:** Ensures developers and AI agents have immediate, local access to design constraints without external dependencies.
- **Alternatives Considered:** External Figma links or ad-hoc code-embedded styles, rejected to prevent drift and offline disconnects.

### 2. Apple System Fonts & Native Vibrancy Materials
- **Decision:** Standardize on `SF Pro` for UI controls and `SF Mono` for text diffs, using `NSVisualEffectView` / SwiftUI `.ultraThinMaterial` / `.thinMaterial` backgrounds.
- **Rationale:** Delivers a native look and feel that harmonizes perfectly with macOS Tahoe and modern macOS versions.
- **Alternatives Considered:** Custom web fonts or opaque flat window backgrounds, rejected because they feel alien on macOS.

### 3. Clear Semantic Diff Palette
- **Decision:** Use high-contrast, accessible green tints for additions and red/coral tints for deletions with specific alpha overlays for Light and Dark modes.
- **Rationale:** Provides instant visual clarity when reviewing speech-to-text corrections and tone edits.

## Risks / Trade-offs

- **[Risk]** Dark Mode and Light Mode material vibrancy may render differently across macOS versions.
  - **Mitigation:** Define fallback system semantic colors (`NSColor.windowBackgroundColor`, `NSColor.labelColor`, etc.) alongside material specifications.
- **[Risk]** Floating HUD sizing might clip very long rewrites.
  - **Mitigation:** Specify flexible minimum/maximum window dimensions (e.g. min 400x200, max 700x500) with smooth native scrollbars.
