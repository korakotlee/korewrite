import AppKit
import SwiftUI

/// AppKit floating window controller hosting the SwiftUI diff preview HUD.
@MainActor
public final class HUDPanelController: NSObject, NSWindowDelegate {
    public let state: HUDViewState
    public private(set) var panel: NSPanel?
    private var eventMonitor: Any?

    public init(state: HUDViewState = HUDViewState()) {
        self.state = state
        super.init()
    }

    /// Cleans up event monitors and closes panel.
    public func cleanup() {
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            self.eventMonitor = nil
        }
        panel?.close()
        panel = nil
    }

    /// Prepares and returns the configured floating NSPanel.
    public func getOrCreatePanel() -> NSPanel {
        if let panel {
            return panel
        }

        let hudView = DiffPreviewHUDView(state: state)
        let hostingController = NSHostingController(rootView: hudView)

        let newPanel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 620, height: 400),
            styleMask: [.titled, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        newPanel.titleVisibility = .hidden
        newPanel.titlebarAppearsTransparent = true
        newPanel.isFloatingPanel = true
        newPanel.level = .floating
        newPanel.backgroundColor = .clear
        newPanel.isOpaque = false
        newPanel.hasShadow = true
        newPanel.isMovableByWindowBackground = true
        newPanel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        newPanel.contentViewController = hostingController
        newPanel.delegate = self

        self.panel = newPanel
        setupKeyEventMonitor()

        return newPanel
    }

    /// Presents the HUD floating window centered on the active screen.
    public func show() {
        let p = getOrCreatePanel()
        p.center()
        p.alphaValue = 0.0
        p.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.18
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            p.animator().alphaValue = 1.0
        }
    }

    /// Dismisses the HUD floating window with a smooth fade-out.
    public func dismiss() {
        guard let p = panel, p.isVisible else { return }

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.12
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            p.animator().alphaValue = 0.0
        }, completionHandler: { [weak self] in
            Task { @MainActor in
                self?.panel?.orderOut(nil)
                self?.panel?.alphaValue = 1.0
            }
        })
    }

    /// Sets up local event monitor to guarantee Return/Esc key interception.
    private func setupKeyEventMonitor() {
        guard eventMonitor == nil else { return }

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, let panel = self.panel, panel.isVisible else {
                return event
            }

            // 53 is Esc keycode, 36 is Return, 76 is Keypad Enter
            switch event.keyCode {
            case 53:
                self.state.cancel()
                self.dismiss()
                return nil
            case 36, 76:
                if case .preview = self.state.status {
                    self.state.apply()
                    self.dismiss()
                    return nil
                }
                return event
            default:
                return event
            }
        }
    }

    // MARK: - NSWindowDelegate
    public func windowWillClose(_ notification: Notification) {
        state.cancel()
    }
}
