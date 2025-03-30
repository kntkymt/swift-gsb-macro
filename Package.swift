// swift-tools-version: 6.0
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "GSB",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "GSB",
            targets: ["GSB"]
        ),
        .executable(
            name: "GSBClient",
            targets: ["GSBClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0-latest"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing.git", from: "0.6.0"),
    ],
    targets: [
        .macro(
            name: "GSBMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(name: "GSB", dependencies: ["GSBMacros"]),
        .executableTarget(name: "GSBClient", dependencies: ["GSB"]),
        .testTarget(
            name: "GSBTests",
            dependencies: [
                "GSBMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                .product(name: "MacroTesting", package: "swift-macro-testing"),
            ]
        ),
    ]
)
