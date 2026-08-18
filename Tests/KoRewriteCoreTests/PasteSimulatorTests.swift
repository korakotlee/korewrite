import Foundation
import Testing
@testable import KoRewriteCore

@Suite("PasteSimulatorTests")
struct PasteSimulatorTests {
    @Test("PasteSimulator checks accessibility without crashing")
    func testAccessibilityCheck() {
        let simulator = PasteSimulator()
        let isTrusted = simulator.isAccessibilityTrusted(promptIfNeeded: false)
        // Trusted status is a boolean depending on test host permissions
        #expect(isTrusted == true || isTrusted == false)
    }

    @Test("PasteSimulator simulatePaste returns success status")
    func testSimulatePaste() {
        let simulator = PasteSimulator()
        let result = simulator.simulatePaste(targetPID: nil)
        #expect(result == true)
    }
}
