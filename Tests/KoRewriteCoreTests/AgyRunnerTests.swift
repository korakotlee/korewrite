import Foundation
import Testing
@testable import KoRewriteCore

struct AgyRunnerTests {
    @Test func testSuccessfulRewriteExecution() async throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("korewrite-runner-test-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let templateManager = PromptTemplateManager(configDirectory: tempDir)
        let mockRunner = MockProcessRunner(
            result: .success(ProcessResult(exitCode: 0, stdout: "Could you please send the document at your earliest convenience?\n", stderr: ""))
        )
        let mockLocator = MockBinaryLocator(resolvedURL: URL(fileURLWithPath: "/usr/local/bin/agy"))

        let runner = AgyRunner(
            templateManager: templateManager,
            processRunner: mockRunner,
            binaryLocator: mockLocator
        )

        let result = try await runner.rewrite(
            text: "can u send me the doc ASAP",
            style: "polite",
            timeout: 5.0
        )

        #expect(result == "Could you please send the document at your earliest convenience?")
        #expect(mockRunner.recordedInvocations.count == 1)

        let invocation = try #require(mockRunner.recordedInvocations.first)
        #expect(invocation.executableURL.path == "/usr/local/bin/agy")
        #expect(invocation.arguments.contains("-p"))
        #expect(invocation.arguments.contains("--disable-slash-commands"))
        #expect(invocation.arguments.contains("--output-format"))
        #expect(invocation.arguments.contains("text"))
        #expect(invocation.timeout == 5.0)
    }

    @Test func testBinaryNotFoundThrowsError() async {
        let templateManager = PromptTemplateManager()
        let mockRunner = MockProcessRunner()
        let mockLocator = MockBinaryLocator(resolvedURL: nil, searchedPaths: ["/usr/local/bin/agy", "/opt/homebrew/bin/agy"])

        let runner = AgyRunner(
            templateManager: templateManager,
            processRunner: mockRunner,
            binaryLocator: mockLocator
        )

        await #expect(throws: KoRewriteError.self) {
            try await runner.rewrite(text: "Hello", style: "polite")
        }
    }

    @Test func testNonExistentStyleThrowsError() async {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("korewrite-runner-test-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let templateManager = PromptTemplateManager(configDirectory: tempDir)
        let mockRunner = MockProcessRunner()
        let mockLocator = MockBinaryLocator(resolvedURL: URL(fileURLWithPath: "/usr/local/bin/agy"))

        let runner = AgyRunner(
            templateManager: templateManager,
            processRunner: mockRunner,
            binaryLocator: mockLocator
        )

        await #expect(throws: KoRewriteError.self) {
            try await runner.rewrite(text: "Hello", style: "non-existent-tone")
        }
    }

    @Test func testProcessNonZeroExitThrowsExecutionFailed() async {
        let templateManager = PromptTemplateManager()
        let mockRunner = MockProcessRunner(
            result: .success(ProcessResult(exitCode: 1, stdout: "", stderr: "API authentication failed"))
        )
        let mockLocator = MockBinaryLocator(resolvedURL: URL(fileURLWithPath: "/usr/local/bin/agy"))

        let runner = AgyRunner(
            templateManager: templateManager,
            processRunner: mockRunner,
            binaryLocator: mockLocator
        )

        do {
            _ = try await runner.rewrite(text: "Hello", style: "polite")
            Issue.record("Expected executionFailed error to be thrown")
        } catch let KoRewriteError.executionFailed(exitCode, stderr) {
            #expect(exitCode == 1)
            #expect(stderr.contains("API authentication failed"))
        } catch {
            Issue.record("Unexpected error thrown: \(error)")
        }
    }

    @Test func testProcessTimeoutThrowsExecutionTimeout() async {
        let templateManager = PromptTemplateManager()
        let mockRunner = MockProcessRunner(
            result: .failure(KoRewriteError.executionTimeout(seconds: 0.1))
        )
        let mockLocator = MockBinaryLocator(resolvedURL: URL(fileURLWithPath: "/usr/local/bin/agy"))

        let runner = AgyRunner(
            templateManager: templateManager,
            processRunner: mockRunner,
            binaryLocator: mockLocator
        )

        do {
            _ = try await runner.rewrite(text: "Hello", style: "polite", timeout: 0.1)
            Issue.record("Expected executionTimeout error to be thrown")
        } catch let KoRewriteError.executionTimeout(seconds) {
            #expect(seconds == 0.1)
        } catch {
            Issue.record("Unexpected error thrown: \(error)")
        }
    }
}
