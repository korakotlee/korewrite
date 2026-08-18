## 1. Prompt Builder Implementation

- [x] 1.1 Update `PromptBuilder.buildPrompt` to prepend `/rewrite\n\n` to assembled prompt payloads in `Sources/KoRewriteCore/PromptBuilder.swift`

## 2. Unit Testing and Verification

- [x] 2.1 Update `PromptBuilderTests` to assert the presence of `/rewrite` prefix in `Tests/KoRewriteCoreTests/PromptBuilderTests.swift`
- [x] 2.2 Run the full test suite (`swift test`) to verify all tests pass
