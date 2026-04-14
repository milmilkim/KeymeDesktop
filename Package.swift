// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KeymeDesktop",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "7.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "KeymeDesktop",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift"),
            ],
            path: "Sources/KeymeDesktop"
        ),
        .testTarget(
            name: "KeymeDesktopTests",
            dependencies: ["KeymeDesktop"],
            path: "Tests/KeymeDesktopTests"
        ),
    ]
)
