import Foundation

/// Model representing a macOS Service definition.
public struct ServiceDefinition: Equatable, Sendable {
    public let style: String
    public let displayName: String
    public let workflowName: String

    public init(style: String, displayName: String, workflowName: String? = nil) {
        self.style = style
        self.displayName = displayName
        self.workflowName = workflowName ?? "\(displayName).workflow"
    }
}

/// Generates and installs macOS Services / Quick Action `.workflow` bundles.
public final class ServiceWorkflowGenerator: @unchecked Sendable {
    private let fileManager: FileManager

    public static let defaultServices: [ServiceDefinition] = [
        ServiceDefinition(style: "polite", displayName: "KoRewrite - Polite"),
        ServiceDefinition(style: "professional", displayName: "KoRewrite - Professional"),
        ServiceDefinition(style: "concise", displayName: "KoRewrite - Concise"),
        ServiceDefinition(style: "casual", displayName: "KoRewrite - Casual"),
        ServiceDefinition(style: "sriburapa", displayName: "KoRewrite - Sriburapa"),
        ServiceDefinition(style: "story", displayName: "KoRewrite - Story"),
        ServiceDefinition(style: "thai-official", displayName: "KoRewrite - Thai Official"),
        ServiceDefinition(style: "translate-to-english", displayName: "KoRewrite - Translate to English"),
        ServiceDefinition(style: "translate-to-thai", displayName: "KoRewrite - Translate to Thai")
    ]

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    /// Generates the Info.plist XML content for a Quick Action Service workflow.
    public func generateInfoPlistXML(serviceName: String) -> String {
        WorkflowTemplateBuilder.generateInfoPlistXML(serviceName: serviceName)
    }

    /// Generates the Automator document.wflow XML content invoking korewrite CLI with style and HUD.
    public func generateDocumentWflowXML(style: String, customBinaryPath: String? = nil) -> String {
        WorkflowTemplateBuilder.generateDocumentWflowXML(style: style, customBinaryPath: customBinaryPath)
    }

    /// Resolves active ServiceDefinition list dynamically from prompt templates in PromptTemplateManager.
    public func resolveServices(from templateManager: PromptTemplateManager = PromptTemplateManager()) -> [ServiceDefinition] {
        let styles = templateManager.listStyles()
        return styles.map { style in
            let displayName = templateManager.getDisplayName(for: style)
            return ServiceDefinition(style: style, displayName: displayName)
        }
    }

    /// Scans destination directory and removes orphan `KoRewrite - *.workflow` bundles that do not match active services.
    @discardableResult
    public func pruneOrphanWorkflows(
        in destinationDirectory: URL,
        activeServices: [ServiceDefinition]
    ) throws -> [URL] {
        guard fileManager.fileExists(atPath: destinationDirectory.path),
              let items = try? fileManager.contentsOfDirectory(atPath: destinationDirectory.path) else {
            return []
        }

        let activeWorkflowNames = Set(activeServices.map { $0.workflowName })
        var removedURLs: [URL] = []

        for item in items {
            guard item.hasPrefix("KoRewrite - ") && item.hasSuffix(".workflow") else {
                continue
            }

            if !activeWorkflowNames.contains(item) {
                let itemURL = destinationDirectory.appendingPathComponent(item)
                try fileManager.removeItem(at: itemURL)
                removedURLs.append(itemURL)
            }
        }

        return removedURLs
    }

    /// Creates and writes all workflow bundles to the specified directory.
    @discardableResult
    public func createWorkflowBundles(
        in destinationDirectory: URL,
        services: [ServiceDefinition] = ServiceWorkflowGenerator.defaultServices,
        customBinaryPath: String? = nil
    ) throws -> [URL] {
        if !fileManager.fileExists(atPath: destinationDirectory.path) {
            try fileManager.createDirectory(at: destinationDirectory, withIntermediateDirectories: true)
        }

        var installedURLs: [URL] = []

        for service in services {
            let workflowURL = destinationDirectory.appendingPathComponent(service.workflowName, isDirectory: true)
            let contentsURL = workflowURL.appendingPathComponent("Contents", isDirectory: true)

            try fileManager.createDirectory(at: contentsURL, withIntermediateDirectories: true)

            let infoPlistPath = contentsURL.appendingPathComponent("Info.plist")
            let infoPlistContent = generateInfoPlistXML(serviceName: service.displayName)
            try infoPlistContent.data(using: .utf8)?.write(to: infoPlistPath, options: .atomic)

            let documentWflowPath = contentsURL.appendingPathComponent("document.wflow")
            let documentWflowContent = generateDocumentWflowXML(style: service.style, customBinaryPath: customBinaryPath)
            try documentWflowContent.data(using: .utf8)?.write(to: documentWflowPath, options: .atomic)

            installedURLs.append(workflowURL)
        }

        return installedURLs
    }

    /// Synchronizes workflows in ~/Library/Services/ with active PromptTemplateManager styles,
    /// removing orphaned workflows and flushing macOS pasteboard cache.
    @discardableResult
    public func syncServices(
        templateManager: PromptTemplateManager = PromptTemplateManager(),
        customServicesDirectory: URL? = nil,
        customBinaryPath: String? = nil
    ) throws -> (installed: [URL], pruned: [URL]) {
        let servicesDir = customServicesDirectory ?? fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Services", isDirectory: true)

        let activeServices = resolveServices(from: templateManager)
        let pruned = try pruneOrphanWorkflows(in: servicesDir, activeServices: activeServices)
        let installed = try createWorkflowBundles(
            in: servicesDir,
            services: activeServices,
            customBinaryPath: customBinaryPath
        )

        refreshMacOSServices()
        return (installed: installed, pruned: pruned)
    }

    /// Installs workflows to ~/Library/Services and refreshes the macOS pasteboard server.
    @discardableResult
    public func installServices(
        services: [ServiceDefinition]? = nil,
        templateManager: PromptTemplateManager = PromptTemplateManager(),
        customServicesDirectory: URL? = nil,
        customBinaryPath: String? = nil
    ) throws -> [URL] {
        let targetServices = services ?? resolveServices(from: templateManager)
        let servicesDir = customServicesDirectory ?? fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Services", isDirectory: true)

        let urls = try createWorkflowBundles(
            in: servicesDir,
            services: targetServices,
            customBinaryPath: customBinaryPath
        )

        refreshMacOSServices()
        return urls
    }

    /// Flushes and refreshes macOS Services cache using pbs tool.
    public func refreshMacOSServices() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/System/Library/CoreServices/pbs")
        process.arguments = ["-flush"]
        try? process.run()
        process.waitUntilExit()
    }
}
