import Foundation
import KoRewriteCore

@main
struct KoRewriteCLI {
    static func main() async {
        let args = CommandLine.arguments

        if args.contains("-h") || args.contains("--help") {
            printUsage()
            return
        }

        let manager = PromptTemplateManager()
        let runner = AgyRunner(templateManager: manager)

        if args.contains("--check") {
            switch runner.checkAvailability() {
            case .success(let url):
                print("agy executable found: \(url.path)")
            case .failure(let error):
                fputs("Error: \(error.localizedDescription)\n", stderr)
                exit(1)
            }
            return
        }

        if args.contains("--init-templates") || args.contains("--init-template") {
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

        if args.contains("--list-styles") {
            let styles = manager.listStyles()
            print("Available styles:")
            for style in styles {
                print("  - \(style)")
            }
            return
        }

        // Parse --style / -s
        var style = "polite"
        if let styleIdx = args.firstIndex(where: { $0 == "--style" || $0 == "-s" }),
           styleIdx + 1 < args.count {
            style = args[styleIdx + 1]
        }

        // Parse --timeout
        var timeout: TimeInterval = 60.0
        if let timeoutIdx = args.firstIndex(where: { $0 == "--timeout" }),
           timeoutIdx + 1 < args.count,
           let parsedTimeout = Double(args[timeoutIdx + 1]) {
            timeout = parsedTimeout
        }

        // Parse input text from --text / -t or stdin
        var inputText: String?
        if let textIdx = args.firstIndex(where: { $0 == "--text" || $0 == "-t" }),
           textIdx + 1 < args.count {
            inputText = args[textIdx + 1]
        } else {
            // Check if stdin has piped data
            if isatty(FileHandle.standardInput.fileDescriptor) == 0 {
                let stdinData = FileHandle.standardInput.readDataToEndOfFile()
                if let str = String(data: stdinData, encoding: .utf8), !str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    inputText = str
                }
            }
        }

        guard let text = inputText, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            if args.count > 1 {
                fputs("Error: No input text provided. Use --text \"<text>\" or pipe text via stdin.\n\n", stderr)
            }
            printUsage()
            exit(args.count > 1 ? 1 : 0)
        }

        do {
            let result = try await runner.rewrite(text: text, style: style, timeout: timeout)
            print(result)
        } catch {
            fputs("Error: \(error.localizedDescription)\n", stderr)
            exit(1)
        }
    }

    private static func printUsage() {
        print("""
KoRewrite - Native macOS In-Place AI Rewriting & Tone Polishing

USAGE:
  korewrite --style <name> --text "<text>"
  echo "<text>" | korewrite --style <name>

OPTIONS:
  -s, --style <name>      Rewrite style to apply (default: polite)
  -t, --text <text>       Input text to rewrite
  --timeout <seconds>     Execution timeout in seconds (default: 60)
  --list-styles           List all available styles
  --init-templates        Initialize ~/.korewrite with default templates
  --check                 Check if agy binary is available
  -h, --help              Show help information
""")
    }
}
