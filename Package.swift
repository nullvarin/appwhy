// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "appwhy",
    products: [
        .library(name: "AppWhyCore", targets: ["AppWhyCore"]),
        .executable(name: "appwhy", targets: ["appwhy"])
    ],
    targets: [
        .target(name: "AppWhyCore"),
        .executableTarget(
            name: "appwhy",
            dependencies: ["AppWhyCore"]
        ),
        .testTarget(
            name: "AppWhyCoreTests",
            dependencies: ["AppWhyCore"]
        )
    ]
)
