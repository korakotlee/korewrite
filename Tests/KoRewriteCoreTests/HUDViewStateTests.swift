import Testing
import Foundation
import os
@testable import KoRewriteCore

@Suite struct HUDViewStateTests {
    @Test func testStateTransitions() {
        let state = HUDViewState()
        #expect(state.status == .idle)

        state.startLoading(originalText: "Draft text")
        #expect(state.status == .loading(originalText: "Draft text"))

        state.showPreview(originalText: "Draft text", rewrittenText: "Polished text")
        if case let .preview(original, rewritten, diff) = state.status {
            #expect(original == "Draft text")
            #expect(rewritten == "Polished text")
            #expect(!diff.isEmpty)
        } else {
            Issue.record("Expected .preview status")
        }

        state.showError(message: "agy binary missing")
        #expect(state.status == .error(message: "agy binary missing"))
    }

    @Test func testApplyCallbackInvocation() {
        let lock = OSAllocatedUnfairLock(initialState: Optional<String>.none)
        let state = HUDViewState(onApply: { text in
            lock.withLock { $0 = text }
        })

        state.showPreview(originalText: "Input", rewrittenText: "Output")
        state.apply()

        let result = lock.withLock { $0 }
        #expect(result == "Output")
        #expect(state.status == .idle)
    }

    @Test func testCancelCallbackInvocation() {
        let lock = OSAllocatedUnfairLock(initialState: false)
        let state = HUDViewState(onCancel: {
            lock.withLock { $0 = true }
        })

        state.startLoading(originalText: "Input")
        state.cancel()

        let result = lock.withLock { $0 }
        #expect(result == true)
        #expect(state.status == .idle)
    }

    @Test func testCopyCallbackAndClipboardInvocation() {
        final class MockClipboard: ClipboardManaging, @unchecked Sendable {
            var copiedText: String?
            func snapshot() -> [PasteboardItemSnapshot] { [] }
            func copyText(_ text: String) { copiedText = text }
            func restoreSnapshot(_ snapshot: [PasteboardItemSnapshot]) {}
        }

        let lock = OSAllocatedUnfairLock(initialState: Optional<String>.none)
        let mockClipboard = MockClipboard()
        let state = HUDViewState(onCopy: { text in
            lock.withLock { $0 = text }
        })

        state.showPreview(originalText: "Draft text", rewrittenText: "Polished text")
        state.copyText(clipboard: mockClipboard)

        let result = lock.withLock { $0 }
        #expect(result == "Polished text")
        #expect(mockClipboard.copiedText == "Polished text")
        #expect(state.status == .idle)
    }
}
