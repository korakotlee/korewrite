import Testing
import Foundation
@testable import KoRewriteCore

@Suite struct TextDiffEngineTests {
    let diffEngine = TextDiffEngine()

    @Test func testEmptyInputs() {
        let diff = diffEngine.computeWordDiff(original: "", rewritten: "")
        #expect(diff.isEmpty)
    }

    @Test func testInsertionOnly() {
        let diff = diffEngine.computeWordDiff(original: "", rewritten: "Hello world")
        #expect(diff.count == 1)
        #expect(diff.first?.kind == .addition)
        #expect(diff.first?.text == "Hello world")
    }

    @Test func testDeletionOnly() {
        let diff = diffEngine.computeWordDiff(original: "Hello world", rewritten: "")
        #expect(diff.count == 1)
        #expect(diff.first?.kind == .deletion)
        #expect(diff.first?.text == "Hello world")
    }

    @Test func testIdenticalStrings() {
        let diff = diffEngine.computeWordDiff(original: "Keep this same", rewritten: "Keep this same")
        #expect(diff.count == 1)
        #expect(diff.first?.kind == .unchanged)
        #expect(diff.first?.text == "Keep this same")
    }

    @Test func testWordModifications() {
        let original = "The quick brown fox"
        let rewritten = "The fast brown fox"
        let diff = diffEngine.computeWordDiff(original: original, rewritten: rewritten)

        // Should detect 'The ' (unchanged), 'quick' (deletion), 'fast' (addition), ' brown fox' (unchanged)
        let additions = diff.filter { $0.kind == .addition }
        let deletions = diff.filter { $0.kind == .deletion }
        let unchanged = diff.filter { $0.kind == .unchanged }

        #expect(additions.map(\.text).contains("fast"))
        #expect(deletions.map(\.text).contains("quick"))
        #expect(unchanged.map(\.text).contains("The "))
        #expect(unchanged.map(\.text).contains(" brown fox"))
    }

    @Test func testTokenizePreservesAllCharacters() {
        let input = "Hello, world! 123 \n test."
        let tokens = TextDiffEngine.tokenize(input)
        #expect(tokens.joined() == input)
    }
}
