import Foundation

public enum PromptTemplateError: LocalizedError, Equatable {
    case templateNotFound(String)
    case directoryCreationFailed(String)
    case unreadableFile(String)

    public var errorDescription: String? {
        switch self {
        case .templateNotFound(let name):
            return "Prompt template '\(name)' not found in configuration directory or bundled defaults."
        case .directoryCreationFailed(let path):
            return "Failed to create configuration directory at path: \(path)"
        case .unreadableFile(let path):
            return "Failed to read template file at path: \(path)"
        }
    }
}

public final class PromptTemplateManager: @unchecked Sendable {
    public let configDirectory: URL
    private let fileManager: FileManager

    public init(
        configDirectory: URL? = nil,
        fileManager: FileManager = .default
    ) {
        if let configDirectory {
            self.configDirectory = configDirectory
        } else {
            self.configDirectory = fileManager.homeDirectoryForCurrentUser
                .appendingPathComponent(".korewrite", isDirectory: true)
        }
        self.fileManager = fileManager
    }

    /// Initializes ~/.korewrite and seeds default templates.
    /// Returns a map of template filename to a boolean indicating whether it was newly written (true) or preserved (false).
    @discardableResult
    public func bootstrap(force: Bool = false) throws -> [String: Bool] {
        if !fileManager.fileExists(atPath: configDirectory.path) {
            do {
                try fileManager.createDirectory(
                    at: configDirectory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                throw PromptTemplateError.directoryCreationFailed(configDirectory.path)
            }
        }

        var results: [String: Bool] = [:]

        for (name, content) in BundledTemplates.all {
            let filename = "\(name).md"
            let targetFileURL = configDirectory.appendingPathComponent(filename)

            if fileManager.fileExists(atPath: targetFileURL.path) && !force {
                results[filename] = false
                continue
            }

            guard let data = content.data(using: .utf8) else {
                continue
            }

            try data.write(to: targetFileURL, options: .atomic)
            results[filename] = true
        }

        return results
    }

    /// Dynamically lists all available style names found in configDirectory (excluding system.md),
    /// falling back to bundled default styles if the directory is missing or empty.
    public func listStyles() -> [String] {
        guard fileManager.fileExists(atPath: configDirectory.path),
              let files = try? fileManager.contentsOfDirectory(atPath: configDirectory.path) else {
            return BundledTemplates.all.keys
                .filter { $0 != "system" }
                .sorted()
        }

        let userStyles = files
            .filter { $0.hasSuffix(".md") && $0 != "system.md" }
            .map { ($0 as NSString).deletingPathExtension }
            .sorted()

        if userStyles.isEmpty {
            return BundledTemplates.all.keys
                .filter { $0 != "system" }
                .sorted()
        }

        return userStyles
    }

    /// Loads the global system prompt, prioritizing the file in configDirectory and falling back to the bundled default.
    public func loadSystemPrompt() throws -> String {
        let systemFileURL = configDirectory.appendingPathComponent("system.md")

        if fileManager.fileExists(atPath: systemFileURL.path) {
            do {
                let content = try String(contentsOf: systemFileURL, encoding: .utf8)
                return content.trimmingCharacters(in: .whitespacesAndNewlines)
            } catch {
                throw PromptTemplateError.unreadableFile(systemFileURL.path)
            }
        }

        if let bundled = BundledTemplates.all["system"] {
            return bundled.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        throw PromptTemplateError.templateNotFound("system")
    }

    /// Loads a specific style prompt by name (e.g. "polite", "professional", "custom-style").
    /// Checks configDirectory first, then bundled templates.
    public func loadStylePrompt(named styleName: String) throws -> String {
        let normalizedName = styleName.hasSuffix(".md")
            ? (styleName as NSString).deletingPathExtension
            : styleName

        let styleFileURL = configDirectory.appendingPathComponent("\(normalizedName).md")

        if fileManager.fileExists(atPath: styleFileURL.path) {
            do {
                let content = try String(contentsOf: styleFileURL, encoding: .utf8)
                return content.trimmingCharacters(in: .whitespacesAndNewlines)
            } catch {
                throw PromptTemplateError.unreadableFile(styleFileURL.path)
            }
        }

        if let bundled = BundledTemplates.all[normalizedName] {
            return bundled.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        throw PromptTemplateError.templateNotFound(normalizedName)
    }
}
