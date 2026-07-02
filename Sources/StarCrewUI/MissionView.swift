import SwiftUI
import StarCrewCore
import StarCrewEngine

/// Mission screen: progress bar, a task from the renderer registry, gentle
/// reaction to an answer (no fail state), explicit finish (see 03_PROGRAM.md §B5).
public struct MissionView: View {
    @State private var model: MissionViewModel
    private let registry: RendererRegistry
    private let language: AppLanguage

    public init(model: MissionViewModel, registry: RendererRegistry = .standard, language: AppLanguage = .ru) {
        _model = State(initialValue: model)
        self.registry = registry
        self.language = language
    }

    public var body: some View {
        VStack(spacing: 20) {
            ProgressView(value: model.progress)
                .tint(.blue)
                .padding(.horizontal)

            if model.isFinished {
                MissionResultView(score: model.score, passed: model.passed)
            } else if let question = model.current {
                registry.view(
                    for: question,
                    context: LocalizedContext(language: language),
                    onAnswer: handleAnswer
                )
                .id(question.id)

                feedbackArea
            }
        }
        .padding(.vertical)
        .animation(.default, value: model.index)
    }

    private func handleAnswer(_ answer: AnyAnswer) {
        model.submit(answer)
    }

    @ViewBuilder
    private var feedbackArea: some View {
        if let grade = model.lastGrade {
            VStack(spacing: 12) {
                if grade.isCorrect {
                    Label("Отличная работа, командир!", systemImage: "star.fill")
                        .foregroundStyle(.green)
                    Button("Дальше") { model.advance() }
                        .buttonStyle(.borderedProminent)
                } else {
                    if let hint = grade.feedback {
                        Label(hint.text(for: language), systemImage: "lightbulb")
                            .foregroundStyle(.secondary)
                    }
                    Text("Попробуй ещё раз")
                        .foregroundStyle(.secondary)
                }
            }
            .font(.headline)
            .padding()
        }
    }
}

struct MissionResultView: View {
    let score: Double
    let passed: Bool

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: passed ? "checkmark.seal.fill" : "arrow.clockwise.circle")
                .font(.system(size: 64))
                .foregroundStyle(passed ? .green : .orange)
            Text(passed ? "Миссия выполнена!" : "Почти получилось — попробуем ещё?")
                .font(.title2)
            Text("Верных ответов: \(Int((score * 100).rounded()))%")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
