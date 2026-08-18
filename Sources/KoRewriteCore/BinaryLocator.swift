import Foundation

public protocol BinaryLocatorProtocol: Sendable {
    func locateBinary(named name: String) -> URL?
    func searchedPaths(for name: String) -> [String]
}

public final class DefaultBinaryLocator: BinaryLocatorProtocol, @unchecked Sendable {
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func candidatePaths(for name: String) -> [String] {
        var paths: [String] = []

        if let pathEnv = ProcessInfo.processInfo.environment["PATH"] {
            for dir in pathEnv.split(separator: ":") {
                let candidate = (String(dir) as NSString).appendingPathComponent(name)
                if !paths.contains(candidate) {
                    paths.append(candidate)
                }
            }
        }

        let homeDir = fileManager.homeDirectoryForCurrentUser.path
        let fallbackDirs = [
            "/opt/homebrew/bin",
            "/usr/local/bin",
            "\(homeDir)/.gemini/antigravity-ide/bin",
            "\(homeDir)/.local/bin",
            "/usr/bin"
        ]

        for dir in fallbackDirs {
            let candidate = (dir as NSString).appendingPathComponent(name)
            if !paths.contains(candidate) {
                paths.append(candidate)
            }
        }

        return paths
    }

    public func locateBinary(named name: String) -> URL? {
        let paths = candidatePaths(for: name)
        for path in paths {
            if fileManager.isExecutableFile(atPath: path) {
                return URL(fileURLWithPath: path)
            }
        }
        return nil
    }

    public func searchedPaths(for name: String) -> [String] {
        return candidatePaths(for: name)
    }
}

public final class MockBinaryLocator: BinaryLocatorProtocol, @unchecked Sendable {
    public var resolvedURL: URL?
    public var searchedPathsList: [String]

    public init(resolvedURL: URL? = nil, searchedPaths: [String] = []) {
        self.resolvedURL = resolvedURL
        self.searchedPathsList = searchedPaths
    }

    public func locateBinary(named name: String) -> URL? {
        return resolvedURL
    }

    public func searchedPaths(for name: String) -> [String] {
        return searchedPathsList
    }
}
