import AppKit
import ApplicationServices
import Foundation

/// Protocol defining simulated keyboard paste events and Accessibility checks.
public protocol PasteSimulating: Sendable {
    func isAccessibilityTrusted(promptIfNeeded: Bool) -> Bool
    func simulatePaste(targetPID: pid_t?) -> Bool
}

/// Default implementation of PasteSimulating using CoreGraphics CGEvent API.
public final class PasteSimulator: PasteSimulating, @unchecked Sendable {
    public init() {}

    /// Checks if Accessibility permissions are granted to synthesize keyboard events.
    public func isAccessibilityTrusted(promptIfNeeded: Bool = false) -> Bool {
        let options = ["AXTrustedCheckOptionPrompt" as CFString: promptIfNeeded as CFBoolean] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    /// Synthesizes Cmd+V keystroke event posted to target process or system event tap.
    @discardableResult
    public func simulatePaste(targetPID: pid_t? = nil) -> Bool {
        let vKeyCode: CGKeyCode = 0x09 // Virtual key code for 'V' on macOS US keyboard layout

        guard let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: vKeyCode, keyDown: true),
              let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: vKeyCode, keyDown: false) else {
            return false
        }

        keyDownEvent.flags = .maskCommand
        keyUpEvent.flags = []

        if let targetPID, targetPID > 0 {
            keyDownEvent.postToPid(targetPID)
            keyUpEvent.postToPid(targetPID)
        } else {
            keyDownEvent.post(tap: .cghidEventTap)
            keyUpEvent.post(tap: .cghidEventTap)
        }

        return true
    }
}
