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

    /// Parses YAML frontmatter enclosed in `---` blocks from the raw markdown template.
    /// Returns a dictionary of key-value pairs and the stripped body content.
    public static func parseFrontmatter(_ content: String) -> (metadata: [String: String], body: String) {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("---") else {
            return ([:], content)
        }

        let lines = content.components(separatedBy: .newlines)
        guard let firstIdx = lines.firstIndex(where: { $0.trimmingCharacters(in: .whitespaces) == "---" }) else {
            return ([:], content)
        }

        // Find matching closing `---`
        let remainingLines = lines.suffix(from: firstIdx + 1)
        guard let secondIdx = remainingLines.firstIndex(where: { $0.trimmingCharacters(in: .whitespaces) == "---" }) else {
            return ([:], content)
        }

        var metadata: [String: String] = [:]
        let frontmatterLines = lines[(firstIdx + 1)..<secondIdx]

        for line in frontmatterLines {
            let lineTrimmed = line.trimmingCharacters(in: .whitespaces)
            if lineTrimmed.isEmpty || lineTrimmed.hasPrefix("#") { continue }
            if let colonIdx = lineTrimmed.firstIndex(of: ":") {
                let key = String(lineTrimmed[..<colonIdx]).trimmingCharacters(in: .whitespaces)
                var value = String(lineTrimmed[lineTrimmed.index(after: colonIdx)...]).trimmingCharacters(in: .whitespaces)
                if (value.hasPrefix("\"") && value.hasSuffix("\"")) || (value.hasPrefix("'") && value.hasSuffix("'")) {
                    value = String(value.dropFirst().dropLast())
                }
                metadata[key] = value
            }
        }

        let bodyLines = lines.suffix(from: secondIdx + 1)
        let body = bodyLines.joined(separator: "\n")
        return (metadata, body)
    }

    /// Formats a raw style name into title-cased fallback display name prefixed with "KoRewrite - ".
    /// e.g. "thai-official" -> "KoRewrite - Thai Official", "polite" -> "KoRewrite - Polite"
    public static func formatDefaultDisplayName(for styleName: String) -> String {
        let normalized = styleName.hasSuffix(".md")
            ? (styleName as NSString).deletingPathExtension
            : styleName

        let words = normalized
            .components(separatedBy: CharacterSet(charactersIn: "-_ "))
            .filter { !$0.isEmpty }
            .map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }

        let formatted = words.joined(separator: " ")
        return "KoRewrite - \(formatted)"
    }

    /// Resolves the human-readable display name for a given style name.
    /// Checks for frontmatter `name:` or `displayName:` in the template file/bundle, falling back to title-cased name.
    public func getDisplayName(for styleName: String) -> String {
        let normalizedName = styleName.hasSuffix(".md")
            ? (styleName as NSString).deletingPathExtension
            : styleName

        let styleFileURL = configDirectory.appendingPathComponent("\(normalizedName).md")

        var rawContent: String?
        if fileManager.fileExists(atPath: styleFileURL.path),
           let content = try? String(contentsOf: styleFileURL, encoding: .utf8) {
            rawContent = content
        } else if let bundled = BundledTemplates.all[normalizedName] {
            rawContent = bundled
        }

        if let rawContent {
            let (metadata, _) = PromptTemplateManager.parseFrontmatter(rawContent)
            if let name = metadata["name"], !name.isEmpty {
                return name
            }
            if let displayName = metadata["displayName"], !displayName.isEmpty {
                return displayName
            }
        }

        return PromptTemplateManager.formatDefaultDisplayName(for: normalizedName)
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
    /// Strips any frontmatter before returning.
    public func loadSystemPrompt() throws -> String {
        let systemFileURL = configDirectory.appendingPathComponent("system.md")

        if fileManager.fileExists(atPath: systemFileURL.path) {
            do {
                let content = try String(contentsOf: systemFileURL, encoding: .utf8)
                let (_, body) = PromptTemplateManager.parseFrontmatter(content)
                return body.trimmingCharacters(in: .whitespacesAndNewlines)
            } catch {
                throw PromptTemplateError.unreadableFile(systemFileURL.path)
            }
        }

        if let bundled = BundledTemplates.all["system"] {
            let (_, body) = PromptTemplateManager.parseFrontmatter(bundled)
            return body.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        throw PromptTemplateError.templateNotFound("system")
    }

    /// Loads a specific style prompt by name (e.g. "polite", "professional", "custom-style").
    /// Checks configDirectory first, then bundled templates. Strips any frontmatter before returning.
    public func loadStylePrompt(named styleName: String) throws -> String {
        let normalizedName = styleName.hasSuffix(".md")
            ? (styleName as NSString).deletingPathExtension
            : styleName

        let styleFileURL = configDirectory.appendingPathComponent("\(normalizedName).md")

        if fileManager.fileExists(atPath: styleFileURL.path) {
            do {
                let content = try String(contentsOf: styleFileURL, encoding: .utf8)
                let (_, body) = PromptTemplateManager.parseFrontmatter(content)
                return body.trimmingCharacters(in: .whitespacesAndNewlines)
            } catch {
                throw PromptTemplateError.unreadableFile(styleFileURL.path)
            }
        }

        if let bundled = BundledTemplates.all[normalizedName] {
            let (_, body) = PromptTemplateManager.parseFrontmatter(bundled)
            return body.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        throw PromptTemplateError.templateNotFound(normalizedName)
    }
}
