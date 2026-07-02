import SwiftUI
import StarCrewCore

/// Renderer for a multiple choice task. Large touch targets; correct/incorrect
/// coded with an icon (not color only) — see 01_ANALYSIS.md §1.3.
struct MultipleChoiceView: View {
    let question: AnyQuestion
    let context: LocalizedContext
    let onAnswer: (AnyAnswer) -> Void

    @State private var selectedID: String?

    private var mc: MultipleChoiceQuestion? { question.base as? MultipleChoiceQuestion }

    var body: some View {
        VStack(spacing: 24) {
            Text(question.prompt.text(for: context.language))
                .font(.title2)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            if let mc {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 16)], spacing: 16) {
                    ForEach(mc.options) { option in
                        optionButton(option, isCorrect: option.id == mc.correctOptionID)
                    }
                }
            }
        }
        .padding()
    }

    @ViewBuilder
    private func optionButton(_ option: MultipleChoiceQuestion.Option, isCorrect: Bool) -> some View {
        let isSelected = selectedID == option.id
        Button {
            selectedID = option.id
            onAnswer(.choice(option.id))
        } label: {
            HStack {
                Text(option.label.text(for: context.language))
                    .font(.title3)
                Spacer(minLength: 0)
                if isSelected {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "arrow.counterclockwise.circle")
                }
            }
            .padding()
            .frame(minHeight: 64)              // large touch target for kids
            .frame(maxWidth: .infinity)
            .background(background(isSelected: isSelected, isCorrect: isCorrect))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(option.label.text(for: context.language))
    }

    private func background(isSelected: Bool, isCorrect: Bool) -> Color {
        guard isSelected else { return Color.secondary.opacity(0.12) }
        return (isCorrect ? Color.green : Color.orange).opacity(0.25)
    }
}
