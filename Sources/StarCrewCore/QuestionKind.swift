import Foundation

/// Task type as an extensible identifier rather than a closed enum: adding a new
/// type does not require touching existing code (see 02_TECH.md §1.2).
public struct QuestionKind: RawRepresentable, Hashable, Sendable, Codable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    // MVP set. The rest (listening, speaking, sequencing, sorting, tapToCount,
    // tracing) are added per 03_PROGRAM.md §B4 without changing the engine.
    public static let multipleChoice = QuestionKind(rawValue: "multipleChoice")
    public static let dragAndDrop = QuestionKind(rawValue: "dragAndDrop")
    public static let fillBlank = QuestionKind(rawValue: "fillBlank")
    public static let matching = QuestionKind(rawValue: "matching")
}

/// Learning skill a task is tagged with. The string tag links content to
/// progress/mastery in persistence (see 02_TECH.md §3.2).
public struct SkillTag: RawRepresentable, Hashable, Sendable, Codable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(rawValue: String) { self.rawValue = rawValue }
    public init(stringLiteral value: String) { self.rawValue = value }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

/// Subject (owned by a crew member). See STARCREW_DOCS.md §2.
public enum Subject: String, Codable, Sendable, CaseIterable {
    case math
    case languageRu
    case languageEn
    case logic
    case science
}
