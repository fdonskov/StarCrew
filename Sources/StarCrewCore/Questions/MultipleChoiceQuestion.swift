import Foundation

/// Single-answer multiple choice task. First type of the Phase 0 vertical slice.
public struct MultipleChoiceQuestion: Question, Decodable {
    public static let kind = QuestionKind.multipleChoice

    public struct Option: Codable, Sendable, Identifiable, Equatable {
        public let id: String
        public let label: LocalizedContent
        public let imageName: String?

        public init(id: String, label: LocalizedContent, imageName: String? = nil) {
            self.id = id
            self.label = label
            self.imageName = imageName
        }
    }

    public let id: String
    public let prompt: LocalizedContent
    public let difficulty: Int
    public let skillTags: [SkillTag]
    public let options: [Option]
    public let correctOptionID: String
    public let hint: LocalizedContent?

    public init(
        id: String,
        prompt: LocalizedContent,
        difficulty: Int,
        skillTags: [SkillTag],
        options: [Option],
        correctOptionID: String,
        hint: LocalizedContent? = nil
    ) {
        self.id = id
        self.prompt = prompt
        self.difficulty = difficulty
        self.skillTags = skillTags
        self.options = options
        self.correctOptionID = correctOptionID
        self.hint = hint
    }

    public func evaluate(_ answer: AnyAnswer) -> Grade {
        guard case let .choice(selected) = answer else { return .wrong }
        let correct = selected == correctOptionID
        return Grade(isCorrect: correct, partialScore: correct ? 1 : 0, feedback: correct ? nil : hint)
    }

    public func selfCheck() throws {
        if options.count < 2 {
            throw ContentError.invalidQuestion(id: id, reason: "need at least 2 options")
        }
        if !options.contains(where: { $0.id == correctOptionID }) {
            throw ContentError.invalidQuestion(id: id, reason: "correctOptionID not found among options")
        }
        if Set(options.map(\.id)).count != options.count {
            throw ContentError.invalidQuestion(id: id, reason: "duplicate option ids")
        }
        if !(1...5).contains(difficulty) {
            throw ContentError.invalidQuestion(id: id, reason: "difficulty out of range 1...5")
        }
    }
}
