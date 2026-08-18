import Foundation
import Testing
@testable import KoRewriteCore

struct BinaryLocatorTests {
    @Test func testDefaultBinaryLocatorSearchedPathsNonEmpty() {
        let locator = DefaultBinaryLocator()
        let paths = locator.searchedPaths(for: "agy")
        #expect(!paths.isEmpty)
        #expect(paths.contains(where: { $0.hasSuffix("/agy") }))
    }

    @Test func testMockBinaryLocatorResolution() {
        let mockURL = URL(fileURLWithPath: "/custom/bin/agy")
        let locator = MockBinaryLocator(resolvedURL: mockURL, searchedPaths: ["/custom/bin/agy"])

        #expect(locator.locateBinary(named: "agy") == mockURL)
        #expect(locator.searchedPaths(for: "agy") == ["/custom/bin/agy"])
    }

    @Test func testAgyRunnerCheckAvailability() {
        let mockURL = URL(fileURLWithPath: "/usr/local/bin/agy")
        let successRunner = AgyRunner(
            binaryLocator: MockBinaryLocator(resolvedURL: mockURL)
        )
        let successResult = successRunner.checkAvailability()
        switch successResult {
        case .success(let url):
            #expect(url == mockURL)
        case .failure:
            Issue.record("Expected availability check to succeed")
        }

        let failureRunner = AgyRunner(
            binaryLocator: MockBinaryLocator(resolvedURL: nil, searchedPaths: ["/usr/bin/agy"])
        )
        let failureResult = failureRunner.checkAvailability()
        switch failureResult {
        case .success:
            Issue.record("Expected availability check to fail")
        case .failure(let error):
            if case let KoRewriteError.binaryNotFound(name, paths) = error {
                #expect(name == "agy")
                #expect(paths == ["/usr/bin/agy"])
            } else {
                Issue.record("Unexpected error: \(error)")
            }
        }
    }
}
