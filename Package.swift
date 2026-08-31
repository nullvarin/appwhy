// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "appwhy",
    products: [
        .library(name: "AppWhyCore", targets: ["AppWhyCore"]),
        .executable(name: "appwhy", targets: ["appwhy"]),
        .executable(name: "AppWhyCoreTestRunner", targets: ["AppWhyCoreTestRunner"])
    ],
    targets: [
        .target(name: "AppWhyCore"),
        .executableTarget(
            name: "appwhy",
            dependencies: ["AppWhyCore"]
        ),
        .executableTarget(
            name: "AppWhyCoreTestRunner",
            dependencies: ["AppWhyCore"]
        )
    ]
)
