import Foundation
import Testing
@testable import KoRewriteCore

@Suite("ServiceWorkflowGeneratorTests")
struct ServiceWorkflowGeneratorTests {
    @Test("InfoPlist XML contains required service definitions and text types")
    func testInfoPlistGeneration() {
        let generator = ServiceWorkflowGenerator()
        let plist = generator.generateInfoPlistXML(serviceName: "KoRewrite - Professional")

        #expect(plist.contains("<string>KoRewrite - Professional</string>"))
        #expect(plist.contains("<string>runWorkflowAsService</string>"))
        #expect(plist.contains("<string>NSStringPboardType</string>"))
        #expect(plist.contains("<string>public.utf8-plain-text</string>"))
    }

    @Test("Document.wflow XML contains style parameter and HUD flag")
    func testDocumentWflowGeneration() {
        let generator = ServiceWorkflowGenerator()
        let wflow = generator.generateDocumentWflowXML(style: "sriburapa")

        #expect(wflow.contains("--style &quot;sriburapa&quot;"))
        #expect(wflow.contains("--hud"))
        #expect(wflow.contains("com.apple.RunShellScript"))
        #expect(wflow.contains("com.apple.Automator.servicesMenu"))
    }

    @Test("Workflow bundles are successfully written to destination directory")
    func testWorkflowBundlesCreation() throws {
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent("korewrite-services-test-\(UUID().uuidString)")
        defer { try? fileManager.removeItem(at: tempDir) }

        let generator = ServiceWorkflowGenerator(fileManager: fileManager)
        let sampleServices = [
            ServiceDefinition(style: "polite", displayName: "KoRewrite - Polite"),
            ServiceDefinition(style: "concise", displayName: "KoRewrite - Concise")
        ]

        let installedURLs = try generator.createWorkflowBundles(in: tempDir, services: sampleServices)

        #expect(installedURLs.count == 2)
        for url in installedURLs {
            #expect(fileManager.fileExists(atPath: url.path))
            let infoPlist = url.appendingPathComponent("Contents/Info.plist")
            let docWflow = url.appendingPathComponent("Contents/document.wflow")
            #expect(fileManager.fileExists(atPath: infoPlist.path))
            #expect(fileManager.fileExists(atPath: docWflow.path))
        }
    }

    @Test("Dynamic service resolution from PromptTemplateManager")
    func testDynamicServiceResolution() throws {
        let fileManager = FileManager.default
        let tempConfigDir = fileManager.temporaryDirectory.appendingPathComponent("korewrite-tmpl-test-\(UUID().uuidString)")
        defer { try? fileManager.removeItem(at: tempConfigDir) }

        let manager = PromptTemplateManager(configDirectory: tempConfigDir, fileManager: fileManager)
        try manager.bootstrap()

        // Add custom template with custom frontmatter
        let customFile = tempConfigDir.appendingPathComponent("pirate.md")
        let customContent = """
        ---
        name: KoRewrite - Pirate Speak
        ---
        Rewrite this in pirate speech.
        """
        try customContent.write(to: customFile, atomically: true, encoding: .utf8)

        let generator = ServiceWorkflowGenerator(fileManager: fileManager)
        let resolved = generator.resolveServices(from: manager)

        let pirateService = resolved.first(where: { $0.style == "pirate" })
        #expect(pirateService != nil)
        #expect(pirateService?.displayName == "KoRewrite - Pirate Speak")
        #expect(pirateService?.workflowName == "KoRewrite - Pirate Speak.workflow")

        let politeService = resolved.first(where: { $0.style == "polite" })
        #expect(politeService != nil)
        #expect(politeService?.displayName == "KoRewrite - Polite")
    }

    @Test("Orphan workflow pruning removes obsolete KoRewrite workflows and preserves non-KoRewrite workflows")
    func testOrphanWorkflowPruning() throws {
        let fileManager = FileManager.default
        let tempServicesDir = fileManager.temporaryDirectory.appendingPathComponent("korewrite-prune-test-\(UUID().uuidString)")
        defer { try? fileManager.removeItem(at: tempServicesDir) }

        try fileManager.createDirectory(at: tempServicesDir, withIntermediateDirectories: true)

        // 1. Create an active KoRewrite workflow
        let activeWorkflow = tempServicesDir.appendingPathComponent("KoRewrite - Polite.workflow")
        try fileManager.createDirectory(at: activeWorkflow, withIntermediateDirectories: true)

        // 2. Create an orphaned KoRewrite workflow
        let orphanWorkflow = tempServicesDir.appendingPathComponent("KoRewrite - Obsolete.workflow")
        try fileManager.createDirectory(at: orphanWorkflow, withIntermediateDirectories: true)

        // 3. Create a third-party non-KoRewrite workflow (must NOT be pruned)
        let thirdPartyWorkflow = tempServicesDir.appendingPathComponent("ThirdPartyService.workflow")
        try fileManager.createDirectory(at: thirdPartyWorkflow, withIntermediateDirectories: true)

        let generator = ServiceWorkflowGenerator(fileManager: fileManager)
        let activeServices = [
            ServiceDefinition(style: "polite", displayName: "KoRewrite - Polite")
        ]

        let pruned = try generator.pruneOrphanWorkflows(in: tempServicesDir, activeServices: activeServices)

        #expect(pruned.count == 1)
        #expect(pruned.first?.lastPathComponent == "KoRewrite - Obsolete.workflow")
        #expect(fileManager.fileExists(atPath: activeWorkflow.path))
        #expect(!fileManager.fileExists(atPath: orphanWorkflow.path))
        #expect(fileManager.fileExists(atPath: thirdPartyWorkflow.path))
    }

    @Test("syncServices creates active workflows and prunes orphans in one pass")
    func testSyncServicesIntegration() throws {
        let fileManager = FileManager.default
        let tempConfigDir = fileManager.temporaryDirectory.appendingPathComponent("korewrite-cfg-\(UUID().uuidString)")
        let tempServicesDir = fileManager.temporaryDirectory.appendingPathComponent("korewrite-svc-\(UUID().uuidString)")
        defer {
            try? fileManager.removeItem(at: tempConfigDir)
            try? fileManager.removeItem(at: tempServicesDir)
        }

        try fileManager.createDirectory(at: tempConfigDir, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: tempServicesDir, withIntermediateDirectories: true)

        let manager = PromptTemplateManager(configDirectory: tempConfigDir, fileManager: fileManager)
        // Only write single custom template
        let customFile = tempConfigDir.appendingPathComponent("thai-official.md")
        try "หนังสือราชการ".write(to: customFile, atomically: true, encoding: .utf8)

        // Create an old orphan in services dir
        let oldOrphan = tempServicesDir.appendingPathComponent("KoRewrite - OldStyle.workflow")
        try fileManager.createDirectory(at: oldOrphan, withIntermediateDirectories: true)

        let generator = ServiceWorkflowGenerator(fileManager: fileManager)
        let result = try generator.syncServices(templateManager: manager, customServicesDirectory: tempServicesDir)

        #expect(result.pruned.count == 1)
        #expect(result.pruned.first?.lastPathComponent == "KoRewrite - OldStyle.workflow")
        #expect(!fileManager.fileExists(atPath: oldOrphan.path))

        #expect(result.installed.count == 1)
        #expect(result.installed.first?.lastPathComponent == "KoRewrite - Thai Official.workflow")
        #expect(fileManager.fileExists(atPath: tempServicesDir.appendingPathComponent("KoRewrite - Thai Official.workflow").path))
    }
}
