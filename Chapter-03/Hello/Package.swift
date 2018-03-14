// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Hello",
  dependencies: [
    .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "2.2.0")),
  ],
  targets: [
    .target(
      name: "Hello",
      dependencies: ["Vapor"]),
  ]
)