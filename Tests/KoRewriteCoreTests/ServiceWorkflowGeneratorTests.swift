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
}
