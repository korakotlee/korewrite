import Foundation

public struct PromptBuilder: Sendable {
    public static func buildPrompt(
        systemPrompt: String,
        stylePrompt: String,
        inputText: String
    ) throws -> String {
        let trimmedInput = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else {
            throw KoRewriteError.emptyInput
        }

        return """
[System Directives]
\(systemPrompt.trimmingCharacters(in: .whitespacesAndNewlines))

[Style Directives]
\(stylePrompt.trimmingCharacters(in: .whitespacesAndNewlines))

[Input Text to Rewrite]
\(inputText)

[Output Instructions]
Output ONLY the rewritten text directly. Do not include markdown preamble, explanations, greetings, quotes, or formatting wrappers unless specifically requested.
"""
    }
}
