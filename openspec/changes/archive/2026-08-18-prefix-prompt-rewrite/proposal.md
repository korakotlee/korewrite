## Why

When KoRewrite executes the `agy` CLI binary, Antigravity loads the user-global prompt rules from `~/.gemini/GEMINI.md`.
Without an explicit bypass, `agy` triggers the Prompt Refinement Protocol (intercepting the prompt, declaring a role, and asking clarifying questions) instead of performing an immediate text rewrite.
Because `GEMINI.md` explicitly specifies that slash commands bypass the Prompt Refinement Protocol, prefixing the composed prompt payload with `/rewrite` ensures `agy` performs direct in-place text rewriting without conversational interception.

## What Changes

- Modify `PromptBuilder.buildPrompt` in `KoRewriteCore` to prepend the `/rewrite` slash command to all composed prompt payloads.
- Update unit tests in `PromptBuilderTests` to assert the presence of the `/rewrite` command prefix at the start of assembled prompts.

## Capabilities

### New Capabilities

### Modified Capabilities
- `core-engine`: Update the unified prompt composition requirement to specify that prompt payloads begin with the `/rewrite` slash command prefix.

## Impact

- `Sources/KoRewriteCore/PromptBuilder.swift`: Prepends `/rewrite` to prompt payloads.
- `Tests/KoRewriteCoreTests/PromptBuilderTests.swift`: Verifies `/rewrite` prefix assembly.
- Subprocess Execution: Ensures `agy` processes text transformation requests directly without conversational interruptions.
