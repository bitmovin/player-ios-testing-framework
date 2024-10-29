// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "PlayerTesting",
    platforms: [
        .iOS(.v14), .tvOS(.v14)
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
        .package(name: "BitmovinPlayerCore", url: "https://github.com/bitmovin/player-ios-core", from: "3.40.0"),
        .package(url: "https://github.com/Quick/Nimble", from: "12.0.0"),
        .package(url: "https://github.com/Quick/Quick", from: "7.0.0"),
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs", from: "9.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PlayerTesting",
            dependencies: [
                "BitmovinPlayerCore",
                "Quick",
                "Nimble",
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs"),
            ]
        )
    ]
)
