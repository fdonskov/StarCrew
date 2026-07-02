import Foundation

public extension CodingUserInfoKey {
    /// Key under which `QuestionRegistry` is placed into `JSONDecoder.userInfo`
    /// for polymorphic task decoding.
    static let questionRegistry = CodingUserInfoKey(rawValue: "starcrew.questionRegistry")!
}

/// Type-erased task: carries domain behavior (`evaluate`) but no UI.
/// Decodable through the registry in `decoder.userInfo` — see `QuestionRegistry`.
public struct AnyQuestion: Identifiable, Sendable, Decodable {
    public let id: String
    public let kind: QuestionKind
    public let prompt: LocalizedContent
    public let difficulty: Int
    public let skillTags: [SkillTag]
    public let base: any Question
    private let _evaluate: @Sendable (AnyAnswer) -> Grade

    public init<Q: Question>(_ q: Q) {
        id = q.id
        kind = Q.kind
        prompt = q.prompt
        difficulty = q.difficulty
        skillTags = q.skillTags
        base = q
        _evaluate = q.evaluate
    }

    public func evaluate(_ answer: AnyAnswer) -> Grade { _evaluate(answer) }
    public func selfCheck() throws { try base.selfCheck() }

    private enum MetaKeys: String, CodingKey { case type }

    public init(from decoder: Decoder) throws {
        let meta = try decoder.container(keyedBy: MetaKeys.self)
        let kind = try meta.decode(QuestionKind.self, forKey: .type)
        guard let registry = decoder.userInfo[.questionRegistry] as? QuestionRegistry else {
            throw ContentError.registryMissing
        }
        self = try registry.makeQuestion(kind: kind, from: decoder)
    }
}

/// Registry of task decoders. Adding a type = one registration (Open/Closed).
public struct QuestionRegistry: @unchecked Sendable {
    private var decoders: [QuestionKind: (Decoder) throws -> AnyQuestion] = [:]

    public init() {}

    public mutating func register<Q: Question & Decodable>(_ type: Q.Type) {
        decoders[Q.kind] = { decoder in AnyQuestion(try Q(from: decoder)) }
    }

    public func makeQuestion(kind: QuestionKind, from decoder: Decoder) throws -> AnyQuestion {
        guard let make = decoders[kind] else {
            throw ContentError.unknownQuestionKind(kind.rawValue)
        }
        return try make(decoder)
    }

    public var registeredKinds: Set<QuestionKind> { Set(decoders.keys) }

    /// Standard registry with all MVP task types.
    public static var standard: QuestionRegistry {
        var registry = QuestionRegistry()
        registry.register(MultipleChoiceQuestion.self)
        return registry
    }
}
