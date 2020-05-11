// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Permission",
    platforms: [
      .iOS(.v10)
    ],
    products: [
      .library(name: "Permission", targets: ["Permission"])
    ],
    targets: [
      .target(name: "Permission", path: "Source"),
      .testTarget(name: "PermissionTests", dependencies: ["Permission"], path: "Tests")
    ]
)

