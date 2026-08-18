import Foundation
import Testing
@testable import KoRewriteCore

struct PromptBuilderTests {
    @Test func testPromptAssemblyIncludesAllComponents() throws {
        let systemPrompt = "Fix speech-to-text slips and grammatical errors."
        let stylePrompt = "Make the tone polite and respectful."
        let inputText = "can u send me the doc ASAP thx"

        let assembled = try PromptBuilder.buildPrompt(
            systemPrompt: systemPrompt,
            stylePrompt: stylePrompt,
            inputText: inputText
        )

        #expect(assembled.hasPrefix("/rewrite\n\n"))
        #expect(assembled.contains(systemPrompt))
        #expect(assembled.contains(stylePrompt))
        #expect(assembled.contains(inputText))
        #expect(assembled.contains("Output ONLY the rewritten text"))
    }

    @Test func testEmptyInputThrowsError() {
        let systemPrompt = "System instructions"
        let stylePrompt = "Style instructions"

        #expect(throws: KoRewriteError.emptyInput) {
            try PromptBuilder.buildPrompt(
                systemPrompt: systemPrompt,
                stylePrompt: stylePrompt,
                inputText: ""
            )
        }

        #expect(throws: KoRewriteError.emptyInput) {
            try PromptBuilder.buildPrompt(
                systemPrompt: systemPrompt,
                stylePrompt: stylePrompt,
                inputText: "   \n\t  "
            )
        }
    }

    @Test func testInputWithSpecialCharactersAndNewlinesPreserved() throws {
        let systemPrompt = "System"
        let stylePrompt = "Polite"
        let multilineInput = "Line 1: Hello!\nLine 2: \"Quoted words\" & symbols <tag>."

        let assembled = try PromptBuilder.buildPrompt(
            systemPrompt: systemPrompt,
            stylePrompt: stylePrompt,
            inputText: multilineInput
        )

        #expect(assembled.contains(multilineInput))
    }
}
