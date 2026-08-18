import Foundation
import Observation

/// Represents the status and payload of the preview HUD.
public enum HUDStatus: Equatable, Sendable {
    case idle
    case loading(originalText: String)
    case preview(originalText: String, rewrittenText: String, diffSegments: [DiffSegment])
    case error(message: String)
}

/// Observable view state managing the presentation lifecycle of the diff preview HUD.
@Observable
public final class HUDViewState: @unchecked Sendable {
    public var status: HUDStatus
    public var onApply: (@Sendable (String) -> Void)?
    public var onCancel: (@Sendable () -> Void)?
    public var onCopy: (@Sendable (String) -> Void)?

    public init(
        status: HUDStatus = .idle,
        onApply: (@Sendable (String) -> Void)? = nil,
        onCancel: (@Sendable () -> Void)? = nil,
        onCopy: (@Sendable (String) -> Void)? = nil
    ) {
        self.status = status
        self.onApply = onApply
        self.onCancel = onCancel
        self.onCopy = onCopy
    }

    /// Transitions to loading state with original user text.
    public func startLoading(originalText: String) {
        self.status = .loading(originalText: originalText)
    }

    /// Transitions to diff preview state, computing word diffs automatically.
    public func showPreview(
        originalText: String,
        rewrittenText: String,
        diffEngine: TextDiffEngine = TextDiffEngine()
    ) {
        let diff = diffEngine.computeWordDiff(original: originalText, rewritten: rewrittenText)
        self.status = .preview(originalText: originalText, rewrittenText: rewrittenText, diffSegments: diff)
    }

    /// Transitions to error state with description.
    public func showError(message: String) {
        self.status = .error(message: message)
    }

    /// Triggers the apply callback with the current rewritten text and resets to idle.
    public func apply() {
        if case let .preview(_, rewrittenText, _) = status {
            let callback = onApply
            self.status = .idle
            callback?(rewrittenText)
        }
    }

    /// Copies the current rewritten text to the clipboard, invokes onCopy callback, and resets to idle.
    public func copyText(clipboard: ClipboardManaging = ClipboardManager()) {
        if case let .preview(_, rewrittenText, _) = status {
            let callback = onCopy
            clipboard.copyText(rewrittenText)
            self.status = .idle
            callback?(rewrittenText)
        }
    }

    /// Triggers the cancel callback and resets to idle.
    public func cancel() {
        let callback = onCancel
        self.status = .idle
        callback?()
    }
}
