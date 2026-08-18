import Testing
import AppKit
import SwiftUI
import os
@testable import KoRewriteCore

@Suite struct HUDPanelControllerTests {
    @MainActor
    @Test func testPanelConfiguration() {
        let state = HUDViewState()
        let controller = HUDPanelController(state: state)
        let panel = controller.getOrCreatePanel()

        #expect(panel.level == .floating)
        #expect(panel.isFloatingPanel == true)
        #expect(panel.styleMask.contains(.nonactivatingPanel))
        #expect(panel.styleMask.contains(.fullSizeContentView))
        #expect(panel.isOpaque == false)
        #expect(panel.backgroundColor == .clear)
    }

    @MainActor
    @Test func testPanelShowAndDismiss() {
        let state = HUDViewState()
        let controller = HUDPanelController(state: state)
        let panel = controller.getOrCreatePanel()

        controller.show()
        #expect(panel.isVisible || panel.windowNumber > 0)

        controller.dismiss()
    }

    @MainActor
    @Test func testHUDViewsRenderWithoutCrash() {
        let state = HUDViewState()

        // 1. Idle state
        let idleView = DiffPreviewHUDView(state: state)
        _ = NSHostingController(rootView: idleView).view

        // 2. Loading state
        state.startLoading(originalText: "Testing input text")
        let loadingView = DiffPreviewHUDView(state: state)
        _ = NSHostingController(rootView: loadingView).view

        // 3. Preview state
        state.showPreview(originalText: "Hello old", rewrittenText: "Hello new world")
        let previewView = DiffPreviewHUDView(state: state)
        _ = NSHostingController(rootView: previewView).view

        // 4. Error state
        state.showError(message: "Failed to locate agy CLI binary")
        let errorView = DiffPreviewHUDView(state: state)
        _ = NSHostingController(rootView: errorView).view
    }

    @MainActor
    @Test func testFlowDiffViewRendering() {
        let segments = [
            DiffSegment(text: "Hello ", kind: .unchanged),
            DiffSegment(text: "world", kind: .deletion),
            DiffSegment(text: "universe", kind: .addition)
        ]
        let diffView = FlowDiffView(segments: segments)
        _ = NSHostingController(rootView: diffView).view
    }

    @MainActor
    @Test func testKeyEventHandling() {
        let copyLock = OSAllocatedUnfairLock(initialState: false)
        let applyLock = OSAllocatedUnfairLock(initialState: false)
        let cancelLock = OSAllocatedUnfairLock(initialState: false)

        let state = HUDViewState(
            onApply: { _ in applyLock.withLock { $0 = true } },
            onCancel: { cancelLock.withLock { $0 = true } },
            onCopy: { _ in copyLock.withLock { $0 = true } }
        )
        let controller = HUDPanelController(state: state)
        _ = controller.getOrCreatePanel()

        // 1. Cmd+C in preview state
        state.showPreview(originalText: "old", rewrittenText: "new")
        let cmdCEvent = NSEvent.keyEvent(
            with: .keyDown,
            location: .zero,
            modifierFlags: .command,
            timestamp: 0,
            windowNumber: 0,
            context: nil,
            characters: "c",
            charactersIgnoringModifiers: "c",
            isARepeat: false,
            keyCode: 8
        )!
        let handledCmdC = controller.handleKeyEvent(cmdCEvent)
        #expect(handledCmdC == nil)
        #expect(copyLock.withLock { $0 } == true)

        // 2. Return in preview state
        state.showPreview(originalText: "old", rewrittenText: "new")
        let returnEvent = NSEvent.keyEvent(
            with: .keyDown,
            location: .zero,
            modifierFlags: [],
            timestamp: 0,
            windowNumber: 0,
            context: nil,
            characters: "\r",
            charactersIgnoringModifiers: "\r",
            isARepeat: false,
            keyCode: 36
        )!
        let handledReturn = controller.handleKeyEvent(returnEvent)
        #expect(handledReturn == nil)
        #expect(applyLock.withLock { $0 } == true)

        // 3. Esc in loading state
        state.startLoading(originalText: "test")
        let escEvent = NSEvent.keyEvent(
            with: .keyDown,
            location: .zero,
            modifierFlags: [],
            timestamp: 0,
            windowNumber: 0,
            context: nil,
            characters: "\u{1B}",
            charactersIgnoringModifiers: "\u{1B}",
            isARepeat: false,
            keyCode: 53
        )!
        let handledEsc = controller.handleKeyEvent(escEvent)
        #expect(handledEsc == nil)
        #expect(cancelLock.withLock { $0 } == true)
    }
}
