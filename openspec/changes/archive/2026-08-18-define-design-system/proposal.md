## Why

KoRewrite requires a cohesive, native macOS visual identity and standardized UI tokens before implementing the floating preview HUD and service integrations. Defining the design system in `DESIGN.md` prevents visual drift, standardizes diff visualization colors, and ensures consistent interaction behaviors across light and dark modes.

## What Changes

- Establish the core visual design language, macOS Human Interface Guidelines (HIG) alignment, and vibrancy materials.
- Define a complete design token system including semantic color palettes (background, border, text, additions, deletions) for both Light and Dark modes.
- Specify typography standards using macOS system fonts (SF Pro) and monospace code diff fonts (SF Mono).
- Specify component layouts, window dimensions, button placements (`[Apply]` / `[Cancel]`), and keybindings (`Enter` / `Esc`) for the floating confirmation HUD modal.
- Document micro-animations, transition curves, and visual feedback states (loading, applying, error, disabled `agy` indicator).
- Populate the root `DESIGN.md` with complete specifications and ASCII/Mermaid component mockups.

## Capabilities

### New Capabilities
- `design-system`: Visual tokens, typography, component layout specs, diff highlighting standards, and interaction guidelines for native macOS HUD and UI components.

### Modified Capabilities

## Impact

- `DESIGN.md`: Populated with comprehensive design tokens, UI specifications, and component layout guidelines.
- Downstream Swift/SwiftUI components (such as the floating confirmation HUD panel and menu bar / service integrations) will consume and adhere to these specifications.
