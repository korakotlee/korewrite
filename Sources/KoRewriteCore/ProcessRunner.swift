import Foundation

public struct ProcessResult: Equatable, Sendable {
    public let exitCode: Int32
    public let stdout: String
    public let stderr: String

    public init(exitCode: Int32, stdout: String, stderr: String) {
        self.exitCode = exitCode
        self.stdout = stdout
        self.stderr = stderr
    }
}

public protocol ProcessRunnerProtocol: Sendable {
    func run(
        executableURL: URL,
        arguments: [String],
        environment: [String: String]?,
        timeout: TimeInterval
    ) async throws -> ProcessResult
}

public final class MockProcessRunner: ProcessRunnerProtocol, @unchecked Sendable {
    public var resultToReturn: Result<ProcessResult, Error>
    public var delay: TimeInterval
    public private(set) var recordedInvocations: [(executableURL: URL, arguments: [String], environment: [String: String]?, timeout: TimeInterval)] = []

    public init(
        result: Result<ProcessResult, Error> = .success(ProcessResult(exitCode: 0, stdout: "", stderr: "")),
        delay: TimeInterval = 0
    ) {
        self.resultToReturn = result
        self.delay = delay
    }

    public func run(
        executableURL: URL,
        arguments: [String],
        environment: [String: String]?,
        timeout: TimeInterval
    ) async throws -> ProcessResult {
        recordedInvocations.append((executableURL, arguments, environment, timeout))

        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }

        switch resultToReturn {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
}
