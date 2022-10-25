// swift-tools-version:5.7
import PackageDescription

let package = Package(
	name: "SwiftJWT",
	platforms: [.macOS(.v12)],
	dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.4")
	],
	targets: [
		.executableTarget(
			name: "SwiftJWT",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser")
			]
		)
	]
)
