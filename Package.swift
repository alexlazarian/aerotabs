// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WorkspaceTabs",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "WorkspaceTabs",
            path: "Sources/WorkspaceTabs",
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-sectcreate", "-Xlinker", "__TEXT", "-Xlinker", "__info_plist", "-Xlinker", "Sources/WorkspaceTabs/Info.plist"])
            ]
        ),
        .testTarget(
            name: "WorkspaceTabsTests",
            dependencies: ["WorkspaceTabs"],
            path: "Tests/WorkspaceTabsTests"
        ),
    ]
)
