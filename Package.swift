// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "FamilyGame",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "FamilyGame",
            targets: ["FamilyGame"]
        )
    ],
    targets: [
        .target(
            name: "FamilyGame",
            path: "ios/FamilyGame/FamilyGame",
            resources: [
                .process("Resources/themes.json")
            ]
        ),
        .testTarget(
            name: "FamilyGameTests",
            dependencies: ["FamilyGame"],
            path: "ios/FamilyGame/FamilyGameTests"
        )
    ]
)
