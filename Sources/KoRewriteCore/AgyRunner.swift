import Foundation

public final class AgyRunner: Sendable {
    public let templateManager: PromptTemplateManager
    public let processRunner: ProcessRunnerProtocol
    public let binaryLocator: BinaryLocatorProtocol
    public let binaryName: String

    public init(
        templateManager: PromptTemplateManager = PromptTemplateManager(),
        processRunner: ProcessRunnerProtocol = SystemProcessRunner(),
        binaryLocator: BinaryLocatorProtocol = DefaultBinaryLocator(),
        binaryName: String = "agy"
    ) {
        self.templateManager = templateManager
        self.processRunner = processRunner
        self.binaryLocator = binaryLocator
        self.binaryName = binaryName
    }

    /// Checks if the AI binary executable is available on the system.
    public func checkAvailability() -> Result<URL, KoRewriteError> {
        if let url = binaryLocator.locateBinary(named: binaryName) {
            return .success(url)
        }
        let paths = binaryLocator.searchedPaths(for: binaryName)
        return .failure(.binaryNotFound(name: binaryName, searchedPaths: paths))
    }

    /// Runs the rewrite pipeline for the given input text and style.
    public func rewrite(
        text: String,
        style: String = "polite",
        timeout: TimeInterval = 60.0
    ) async throws -> String {
        // 1. Locate binary
        guard let binaryURL = binaryLocator.locateBinary(named: binaryName) else {
            let paths = binaryLocator.searchedPaths(for: binaryName)
            throw KoRewriteError.binaryNotFound(name: binaryName, searchedPaths: paths)
        }

        // 2. Load system prompt
        let systemPrompt = try templateManager.loadSystemPrompt()

        // 3. Load style prompt
        let stylePrompt: String
        do {
            stylePrompt = try templateManager.loadStylePrompt(named: style)
        } catch {
            let available = templateManager.listStyles()
            throw KoRewriteError.styleNotFound(style: style, availableStyles: available)
        }

        // 4. Build combined prompt
        let fullPrompt = try PromptBuilder.buildPrompt(
            systemPrompt: systemPrompt,
            stylePrompt: stylePrompt,
            inputText: text
        )

        // 5. Execute process
        let arguments = [
            "-p", fullPrompt,
            "--disable-slash-commands",
            "--output-format", "text"
        ]

        let result = try await processRunner.run(
            executableURL: binaryURL,
            arguments: arguments,
            environment: nil,
            timeout: timeout
        )

        if result.exitCode != 0 {
            throw KoRewriteError.executionFailed(
                exitCode: result.exitCode,
                stderr: result.stderr
            )
        }

        return result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
