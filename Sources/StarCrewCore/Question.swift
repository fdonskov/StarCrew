import Foundation

/// A child's answer in generic form. Extended as new task types are added.
public enum AnyAnswer: Sendable, Equatable {
    case choice(String)     // an option with this id was picked (multipleChoice)
    case text(String)       // typed text (fillBlank)
    case ordering([String]) // element order (sequencing)
    case pairs([String: String]) // matched pairs (matching)
    case none
}

/// Result of evaluating an answer. `partialScore` supports tasks with partial
/// credit (matching, dragAndDrop, sequencing).
public struct Grade: Sendable, Equatable {
    public let isCorrect: Bool
    public let partialScore: Double   // 0...1
    public let feedback: LocalizedContent?

    public init(isCorrect: Bool, partialScore: Double, feedback: LocalizedContent? = nil) {
        self.isCorrect = isCorrect
        self.partialScore = partialScore
        self.feedback = feedback
    }

    public static let wrong = Grade(isCorrect: false, partialScore: 0)
    public static let correct = Grade(isCorrect: true, partialScore: 1)
}

/// Base task protocol. Answer evaluation (`evaluate`) is a pure function, tested
/// without UI (see 02_TECH.md §1.2).
public protocol Question: Identifiable, Sendable {
    static var kind: QuestionKind { get }
    var id: String { get }
    var prompt: LocalizedContent { get }
    var difficulty: Int { get }        // 1...5
    var skillTags: [SkillTag] { get }
    func evaluate(_ answer: AnyAnswer) -> Grade
    /// Content invariants checked by the validator (see 02_TECH.md §2).
    func selfCheck() throws
}

public extension Question {
    func selfCheck() throws {}
}

public enum ContentError: Error, Equatable {
    case unknownQuestionKind(String)
    case registryMissing
    case invalidQuestion(id: String, reason: String)
}
