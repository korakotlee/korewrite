import Foundation

public enum KoRewriteError: LocalizedError, Equatable, Sendable {
    case emptyInput
    case styleNotFound(style: String, availableStyles: [String])
    case binaryNotFound(name: String, searchedPaths: [String])
    case executionTimeout(seconds: TimeInterval)
    case executionFailed(exitCode: Int32, stderr: String)
    case unreadableOutput

    public var errorDescription: String? {
        switch self {
        case .emptyInput:
            return "Input text is empty."
        case .styleNotFound(let style, let availableStyles):
            let available = availableStyles.isEmpty ? "none" : availableStyles.joined(separator: ", ")
            return "Rewrite style '\(style)' not found. Available styles: \(available)"
        case .binaryNotFound(let name, let searchedPaths):
            return "Executable '\(name)' not found. Checked paths:\n" + searchedPaths.map { "  - \($0)" }.joined(separator: "\n")
        case .executionTimeout(let seconds):
            return "Process execution timed out after \(seconds) seconds."
        case .executionFailed(let exitCode, let stderr):
            let trimmedStderr = stderr.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedStderr.isEmpty {
                return "Process failed with exit code \(exitCode)."
            }
            return "Process failed with exit code \(exitCode): \(trimmedStderr)"
        case .unreadableOutput:
            return "Failed to decode process output as UTF-8 string."
        }
    }
}
