// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AeroTabs",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "AeroTabs",
            path: "Sources/AeroTabs",
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-sectcreate", "-Xlinker", "__TEXT", "-Xlinker", "__info_plist", "-Xlinker", "Sources/AeroTabs/Info.plist"])
            ]
        ),
        .testTarget(
            name: "AeroTabsTests",
            dependencies: ["AeroTabs"],
            path: "Tests/AeroTabsTests"
        ),
    ]
)
