// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "skip-model-native",
    defaultLocalization: "en",
    platforms: [.iOS(.v16), .macOS(.v13), .tvOS(.v16), .watchOS(.v9), .macCatalyst(.v16)],
    products: [
        .library(name: "SkipModelNative", targets: ["SkipModelNative"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "1.2.18"),
        .package(url: "https://source.skip.tools/skip-foundation.git", from: "1.2.7"),
        .package(url: "https://github.com/OpenCombine/OpenCombine.git", from: "0.14.0")
    ],
    targets: [
        .target(
            name: "SkipModelNative",
            dependencies: [
                .product(name: "SkipFoundation", package: "skip-foundation"),
                .product(name: "OpenCombineFoundation", package: "OpenCombine")
            ],
            plugins: [.plugin(name: "skipstone", package: "skip")]
        ),
        .testTarget(
            name: "SkipModelNativeTests",
            dependencies: ["SkipModelNative", .product(name: "SkipTest", package: "skip")],
            plugins: [.plugin(name: "skipstone", package: "skip")]
        ),
    ]
)
