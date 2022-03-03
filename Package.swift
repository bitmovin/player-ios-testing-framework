// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "PlayerTesting",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PlayerTesting",
            targets: ["PlayerTesting"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "BitmovinPlayer", url: "https://github.com/bitmovin/player-ios", from: "3.15.0"),
        .package(url: "https://github.com/Quick/Nimble", from: "9.0.0"),
        .package(url: "https://github.com/Quick/Quick", from: "4.0.0"),
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs", from: "9.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PlayerTesting",
            dependencies: [
                "BitmovinPlayer",
                "Quick",
                "Nimble",
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs"),
            ]
        )
    ]
)
