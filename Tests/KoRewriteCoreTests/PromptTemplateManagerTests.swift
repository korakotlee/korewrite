import Foundation
import Testing
@testable import KoRewriteCore

struct PromptTemplateManagerTests {
    @Test func testBundledTemplatesFallback() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("korewrite-test-\(UUID().uuidString)")
        let manager = PromptTemplateManager(configDirectory: tempDir)

        let styles = manager.listStyles()
        #expect(styles.contains("polite"))
        #expect(styles.contains("professional"))
        #expect(styles.contains("casual"))
        #expect(styles.contains("concise"))
        #expect(!styles.contains("system"))

        let systemPrompt = try manager.loadSystemPrompt()
        #expect(systemPrompt.contains("KoRewrite"))
        #expect(systemPrompt.contains("speech-to-text"))

        let politePrompt = try manager.loadStylePrompt(named: "polite")
        #expect(politePrompt.contains("polite"))
    }

    @Test func testBootstrapSeeding() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("korewrite-test-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let manager = PromptTemplateManager(configDirectory: tempDir)
        let results = try manager.bootstrap()

        #expect(results["system.md"] == true)
        #expect(results["polite.md"] == true)
        #expect(results["professional.md"] == true)
        #expect(results["casual.md"] == true)
        #expect(results["concise.md"] == true)

        let systemContent = try manager.loadSystemPrompt()
        #expect(systemContent.contains("Core Directives"))

        // Second bootstrap without force should preserve existing files
        let secondResults = try manager.bootstrap(force: false)
        #expect(secondResults["system.md"] == false)
        #expect(secondResults["polite.md"] == false)
    }

    @Test func testSafeNonOverwriteBehavior() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("korewrite-test-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let manager = PromptTemplateManager(configDirectory: tempDir)
        try manager.bootstrap()

        // Modify polite.md with custom text
        let customPolite = "Custom polite user instructions"
        let politeURL = tempDir.appendingPathComponent("polite.md")
        try customPolite.write(to: politeURL, atomically: true, encoding: .utf8)

        // Bootstrap again without force
        try manager.bootstrap(force: false)
        let loadedPolite = try manager.loadStylePrompt(named: "polite")
        #expect(loadedPolite == customPolite)

        // Bootstrap with force should overwrite
        try manager.bootstrap(force: true)
        let reloadedPolite = try manager.loadStylePrompt(named: "polite")
        #expect(reloadedPolite != customPolite)
        #expect(reloadedPolite.contains("polite"))
    }

    @Test func testDynamicCustomStyleDiscovery() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("korewrite-test-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let manager = PromptTemplateManager(configDirectory: tempDir)
        try manager.bootstrap()

        // Add a custom style file
        let customStyleURL = tempDir.appendingPathComponent("thai-formal.md")
        let customContent = "เขียนใหม่ด้วยภาษาไทยที่เป็นทางการ สละสลวย"
        try customContent.write(to: customStyleURL, atomically: true, encoding: .utf8)

        let styles = manager.listStyles()
        #expect(styles.contains("thai-formal"))

        let loadedCustom = try manager.loadStylePrompt(named: "thai-formal")
        #expect(loadedCustom == customContent)
    }

    @Test func testUnknownTemplateThrowsError() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("korewrite-test-\(UUID().uuidString)")
        let manager = PromptTemplateManager(configDirectory: tempDir)

        #expect(throws: PromptTemplateError.self) {
            try manager.loadStylePrompt(named: "non-existent-style")
        }
    }
}
