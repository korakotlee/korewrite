import Testing
import AppKit
import SwiftUI
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
}
