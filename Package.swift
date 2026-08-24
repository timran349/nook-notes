// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NookNotes",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "NookNotes",
            targets: ["NookNotes"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "NookNotes",
            dependencies: [],
            path: "Sources"
        )
    ]
)
