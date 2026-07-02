// swift-tools-version: 6.0
import PackageDescription

// StarCrew module layout (see 02_TECH.md §1.1).
// Core and content have no SwiftUI/SwiftData dependency and are tested on the host.
// macOS is added as a build platform so `swift test` runs the logic without a simulator.
let package = Package(
    name: "StarCrew",
    defaultLocalization: "ru",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "StarCrewCore", targets: ["StarCrewCore"]),
        .library(name: "StarCrewContent", targets: ["StarCrewContent"]),
        .library(name: "StarCrewPersistence", targets: ["StarCrewPersistence"]),
        .library(name: "StarCrewEngine", targets: ["StarCrewEngine"]),
        .library(name: "StarCrewUI", targets: ["StarCrewUI"]),
    ],
    targets: [
        .target(name: "StarCrewCore"),
        .target(
            name: "StarCrewContent",
            dependencies: ["StarCrewCore"],
            resources: [.process("Resources")]
        ),
        .target(name: "StarCrewPersistence", dependencies: ["StarCrewCore"]),
        .target(name: "StarCrewEngine", dependencies: ["StarCrewCore", "StarCrewContent"]),
        .target(
            name: "StarCrewUI",
            dependencies: ["StarCrewCore", "StarCrewEngine"],
            resources: [.process("Resources")]
        ),
        .testTarget(name: "StarCrewCoreTests", dependencies: ["StarCrewCore"]),
        .testTarget(name: "StarCrewContentTests", dependencies: ["StarCrewContent"]),
        .testTarget(name: "StarCrewPersistenceTests", dependencies: ["StarCrewPersistence"]),
    ]
)
