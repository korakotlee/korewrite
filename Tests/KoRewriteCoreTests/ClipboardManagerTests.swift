import AppKit
import Foundation
import Testing
@testable import KoRewriteCore

@Suite("ClipboardManagerTests")
struct ClipboardManagerTests {
    @Test("Snapshot captures and restores string content accurately")
    func testSnapshotAndRestore() {
        let pasteboard = NSPasteboard(name: NSPasteboard.Name("com.korewrite.test.pasteboard.\(UUID().uuidString)"))
        let manager = ClipboardManager(pasteboard: pasteboard)

        // Seed initial pasteboard
        pasteboard.clearContents()
        pasteboard.setString("Original Content", forType: .string)

        // Capture snapshot
        let snapshot = manager.snapshot()
        #expect(!snapshot.isEmpty)

        // Overwrite pasteboard
        manager.copyText("New Rewritten Content")
        #expect(pasteboard.string(forType: .string) == "New Rewritten Content")

        // Restore snapshot
        manager.restoreSnapshot(snapshot)
        #expect(pasteboard.string(forType: .string) == "Original Content")
    }

    @Test("Snapshot handles empty pasteboard safely")
    func testEmptyPasteboardSnapshot() {
        let pasteboard = NSPasteboard(name: NSPasteboard.Name("com.korewrite.test.empty.\(UUID().uuidString)"))
        let manager = ClipboardManager(pasteboard: pasteboard)

        pasteboard.clearContents()
        let snapshot = manager.snapshot()
        #expect(snapshot.isEmpty)

        manager.restoreSnapshot(snapshot)
        #expect(pasteboard.pasteboardItems?.isEmpty ?? true)
    }

    @Test("replaceWithTextAndRestore invokes paste block and restores state")
    func testReplaceWithTextAndRestore() async {
        let pasteboard = NSPasteboard(name: NSPasteboard.Name("com.korewrite.test.replace.\(UUID().uuidString)"))
        let manager = ClipboardManager(pasteboard: pasteboard)

        pasteboard.clearContents()
        pasteboard.setString("Saved Initial Text", forType: .string)

        var pasteExecuted = false

        await withCheckedContinuation { continuation in
            manager.replaceWithTextAndRestore(
                "Temporary Rewritten Text",
                delay: 0.05,
                performPaste: {
                    pasteExecuted = true
                    #expect(pasteboard.string(forType: .string) == "Temporary Rewritten Text")
                },
                onComplete: {
                    continuation.resume()
                }
            )
        }

        #expect(pasteExecuted == true)
        #expect(pasteboard.string(forType: .string) == "Saved Initial Text")
    }
}
