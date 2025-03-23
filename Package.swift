// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MacClient",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "MacClient",
            targets: ["MacClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.1"),
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.6"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
        .package(url: "https://github.com/ZeeZide/CodeEditor.git", from: "1.2.2")
    ],
    targets: [
        .target(
            name: "MacClient",
            dependencies: [
                "Alamofire",
                "Starscream",
                "KeychainAccess",
                "CodeEditor"
            ]),
        .testTarget(
            name: "MacClientTests",
            dependencies: ["MacClient"]),
    ]
)