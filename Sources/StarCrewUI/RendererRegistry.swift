import SwiftUI
import StarCrewCore

/// Registry of task renderers (plugin-style). The mission screen does not know the
/// concrete types — it fetches a View by `kind` (see 02_TECH.md §1.2). Adding a
/// type = one registration.
@MainActor
public final class RendererRegistry {
    public typealias AnswerHandler = (AnyAnswer) -> Void
    private var renderers: [QuestionKind: (AnyQuestion, LocalizedContext, @escaping AnswerHandler) -> AnyView] = [:]

    public init() {}

    public func register(
        _ kind: QuestionKind,
        @ViewBuilder _ make: @escaping (AnyQuestion, LocalizedContext, @escaping AnswerHandler) -> some View
    ) {
        renderers[kind] = { question, context, onAnswer in
            AnyView(make(question, context, onAnswer))
        }
    }

    public func view(
        for question: AnyQuestion,
        context: LocalizedContext,
        onAnswer: @escaping AnswerHandler
    ) -> AnyView {
        renderers[question.kind]?(question, context, onAnswer)
            ?? AnyView(UnsupportedQuestionView(kind: question.kind))
    }

    /// Standard registry with all MVP task types.
    public static var standard: RendererRegistry {
        let registry = RendererRegistry()
        registry.register(.multipleChoice) { question, context, onAnswer in
            MultipleChoiceView(question: question, context: context, onAnswer: onAnswer)
        }
        return registry
    }
}

/// Render context: current content language (see 02_TECH.md §6).
public struct LocalizedContext: Sendable {
    public var language: AppLanguage
    public init(language: AppLanguage) { self.language = language }
}

struct UnsupportedQuestionView: View {
    let kind: QuestionKind
    var body: some View {
        ContentUnavailableView(
            "Тип задания недоступен",
            systemImage: "questionmark.diamond",
            description: Text(kind.rawValue)
        )
    }
}
