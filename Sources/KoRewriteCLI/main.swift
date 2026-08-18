import Foundation
import KoRewriteCore

@main
struct KoRewriteCLI {
    static func main() {
        let manager = PromptTemplateManager()

        if CommandLine.arguments.contains("--init-templates") || CommandLine.arguments.contains("--init-template") {
            do {
                let results = try manager.bootstrap()
                print("Initialized templates in \(manager.configDirectory.path):")
                for (name, created) in results.sorted(by: { $0.key < $1.key }) {
                    print("  - \(name): \(created ? "created" : "preserved")")
                }
            } catch {
                fputs("Error initializing templates: \(error.localizedDescription)\n", stderr)
                exit(1)
            }
            return
        }

        if CommandLine.arguments.contains("--list-styles") {
            let styles = manager.listStyles()
            print("Available styles:")
            for style in styles {
                print("  - \(style)")
            }
            return
        }

        print("KoRewrite CLI v0.1.0")
        print("Use --init-templates to set up ~/.korewrite, or --list-styles to view available rewrite styles.")
    }
}
