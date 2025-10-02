// swift-tools-version: 6.0

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Steps",
    platforms: [.macOS(.v13), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "StepMacro",
            targets: ["StepMacro"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "600.0.1"),
        .package(url: "https://github.com/stefanspringer1/Pipeline.git", from: "0.0.45"),
//        .package(path: "../Pipeline"),
    ],
    targets: [
        .macro(
            name: "StepMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                "Pipeline",
            ]
        ),
        .target(
            name: "StepMacro",
            dependencies: ["StepMacros"]
        ),
        .testTarget(
            name: "MacroTests",
            dependencies: [
                "StepMacro",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                "Pipeline",
            ],
            swiftSettings: [
                .enableExperimentalFeature("BodyMacros"),
            ]
        ),
    ]
)
