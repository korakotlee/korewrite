import AppKit
import Foundation

/// Represents details of a captured macOS application.
public struct TargetAppInfo: Equatable, Sendable {
    public let processIdentifier: pid_t
    public let bundleIdentifier: String?
    public let localizedName: String?

    public init(
        processIdentifier: pid_t,
        bundleIdentifier: String? = nil,
        localizedName: String? = nil
    ) {
        self.processIdentifier = processIdentifier
        self.bundleIdentifier = bundleIdentifier
        self.localizedName = localizedName
    }
}

/// Protocol defining application tracking and focus reactivation capabilities.
public protocol ActiveAppTracking: Sendable {
    func captureFrontmostApplication() -> TargetAppInfo?
    func activateApplication(processIdentifier: pid_t) -> Bool
}

/// Default implementation of active application tracking using NSWorkspace.
public final class ActiveAppTracker: ActiveAppTracking, @unchecked Sendable {
    public init() {}

    /// Captures the currently active frontmost application, filtering out the current process.
    public func captureFrontmostApplication() -> TargetAppInfo? {
        let currentPID = ProcessInfo.processInfo.processIdentifier
        if let frontApp = NSWorkspace.shared.frontmostApplication,
           frontApp.processIdentifier != currentPID {
            return TargetAppInfo(
                processIdentifier: frontApp.processIdentifier,
                bundleIdentifier: frontApp.bundleIdentifier,
                localizedName: frontApp.localizedName
            )
        }

        // Search running applications if frontmost happens to be self
        let candidates = NSWorkspace.shared.runningApplications.filter {
            $0.processIdentifier != currentPID &&
            $0.activationPolicy == .regular &&
            !$0.isTerminated
        }

        if let topCandidate = candidates.first {
            return TargetAppInfo(
                processIdentifier: topCandidate.processIdentifier,
                bundleIdentifier: topCandidate.bundleIdentifier,
                localizedName: topCandidate.localizedName
            )
        }

        return nil
    }

    /// Activates the target application identified by process ID.
    @discardableResult
    public func activateApplication(processIdentifier: pid_t) -> Bool {
        guard let app = NSRunningApplication(processIdentifier: processIdentifier),
              !app.isTerminated else {
            return false
        }
        return app.activate()
    }
}
