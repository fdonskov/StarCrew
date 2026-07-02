import Foundation
import StarCrewCore

// Content models live in memory only, loaded from JSON in the bundle
// (see STARCREW_DOCS.md §5, 02_TECH.md §2). Progress is stored separately in SwiftData.

public struct MissionContent: Decodable, Sendable, Identifiable {
    public let id: String
    public let crewMemberID: String
    public let passingThreshold: Double   // "pass the mission" threshold, ~0.75 (see 03_PROGRAM.md §B6)
    public let questions: [AnyQuestion]
}

public struct PlanetContent: Decodable, Sendable, Identifiable {
    public let id: String
    public let name: LocalizedContent
    public let subject: Subject
    public let sector: Int
    public let missions: [MissionContent]
}

public struct ContentPack: Decodable, Sendable {
    public let contentSchemaVersion: Int
    public let planet: PlanetContent
}
