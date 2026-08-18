import AppKit
import Foundation
import Testing
@testable import KoRewriteCore

@Suite("ActiveAppTrackerTests")
struct ActiveAppTrackerTests {
    @Test("TargetAppInfo holds process, bundle, and localized details")
    func testTargetAppInfoInitialization() {
        let info = TargetAppInfo(
            processIdentifier: 1234,
            bundleIdentifier: "com.apple.Notes",
            localizedName: "Notes"
        )

        #expect(info.processIdentifier == 1234)
        #expect(info.bundleIdentifier == "com.apple.Notes")
        #expect(info.localizedName == "Notes")
    }

    @Test("ActiveAppTracker captures frontmost or running applications")
    func testCaptureApplication() {
        let tracker = ActiveAppTracker()
        let target = tracker.captureFrontmostApplication()

        // In test runners on macOS, target might be nil or the parent test runner process
        if let target {
            #expect(target.processIdentifier > 0)
        }
    }

    @Test("activateApplication gracefully handles non-existent PID")
    func testActivateInvalidPID() {
        let tracker = ActiveAppTracker()
        let result = tracker.activateApplication(processIdentifier: 999999)
        #expect(result == false)
    }
}
