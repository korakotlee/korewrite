// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "KoRewrite",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "KoRewriteCore",
            targets: ["KoRewriteCore"]
        ),
        .executable(
            name: "korewrite",
            targets: ["KoRewriteCLI"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "KoRewriteCore",
            dependencies: [],
            resources: [
                .process("Resources")
            ]
        ),
        .executableTarget(
            name: "KoRewriteCLI",
            dependencies: ["KoRewriteCore"]
        ),
        .testTarget(
            name: "KoRewriteCoreTests",
            dependencies: ["KoRewriteCore"]
        )
    ]
)
