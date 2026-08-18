import Foundation

public final class SystemProcessRunner: ProcessRunnerProtocol, @unchecked Sendable {
    public init() {}

    public func run(
        executableURL: URL,
        arguments: [String],
        environment: [String: String]?,
        timeout: TimeInterval
    ) async throws -> ProcessResult {
        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments

        if let environment {
            var env = ProcessInfo.processInfo.environment
            for (key, value) in environment {
                env[key] = value
            }
            process.environment = env
        }

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        var stdoutData = Data()
        var stderrData = Data()

        let stdoutSource = DispatchSource.makeReadSource(
            fileDescriptor: stdoutPipe.fileHandleForReading.fileDescriptor,
            queue: DispatchQueue.global(qos: .userInitiated)
        )
        let stderrSource = DispatchSource.makeReadSource(
            fileDescriptor: stderrPipe.fileHandleForReading.fileDescriptor,
            queue: DispatchQueue.global(qos: .userInitiated)
        )

        stdoutSource.setEventHandler {
            let data = stdoutPipe.fileHandleForReading.availableData
            if !data.isEmpty {
                stdoutData.append(data)
            }
        }

        stderrSource.setEventHandler {
            let data = stderrPipe.fileHandleForReading.availableData
            if !data.isEmpty {
                stderrData.append(data)
            }
        }

        stdoutSource.resume()
        stderrSource.resume()

        do {
            try process.run()
        } catch {
            stdoutSource.cancel()
            stderrSource.cancel()
            throw error
        }

        let isCompleted = await withTaskGroup(of: Bool.self) { group -> Bool in
            // Worker task: wait for process exit
            group.addTask {
                process.waitUntilExit()
                return true
            }

            // Timeout watchdog
            group.addTask {
                try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                return false
            }

            if let firstResult = await group.next() {
                if !firstResult {
                    // Timeout hit first
                    process.terminate()
                }
                group.cancelAll()
                return firstResult
            }
            return false
        }

        // Cancel sources and drain any remaining bytes
        stdoutSource.cancel()
        stderrSource.cancel()

        let remainingOut = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        stdoutData.append(remainingOut)

        let remainingErr = stderrPipe.fileHandleForReading.readDataToEndOfFile()
        stderrData.append(remainingErr)

        guard isCompleted else {
            throw KoRewriteError.executionTimeout(seconds: timeout)
        }

        guard let stdoutString = String(data: stdoutData, encoding: .utf8),
              let stderrString = String(data: stderrData, encoding: .utf8) else {
            throw KoRewriteError.unreadableOutput
        }

        return ProcessResult(
            exitCode: process.terminationStatus,
            stdout: stdoutString,
            stderr: stderrString
        )
    }
}
