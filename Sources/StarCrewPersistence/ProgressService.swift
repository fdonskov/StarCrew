import Foundation
import SwiftData
import StarCrewCore

/// Bridge between a task result (Core) and progress storage (SwiftData).
/// Updates per-skill mastery via EWMA (see 02_TECH.md §4). The full adaptivity
/// and spaced-repetition engine is Phase 2.
@MainActor
public final class ProgressService {
    private let context: ModelContext
    private let alpha: Double   // weight of the new observation in EWMA

    public init(context: ModelContext, alpha: Double = 0.3) {
        self.context = context
        self.alpha = alpha
    }

    /// Records an answer result: raises/lowers mastery for each of the task's skills.
    public func record(question: AnyQuestion, grade: Grade, for learner: Learner) {
        let observed = grade.isCorrect ? 1.0 : grade.partialScore
        for tag in question.skillTags {
            let progress = existing(tag: tag.rawValue, learner: learner)
                ?? {
                    let created = SkillProgress(skillTag: tag.rawValue)
                    created.learner = learner
                    context.insert(created)
                    return created
                }()
            progress.mastery = (1 - alpha) * progress.mastery + alpha * observed
            progress.attempts += 1
        }
    }

    private func existing(tag: String, learner: Learner) -> SkillProgress? {
        learner.skills.first { $0.skillTag == tag }
    }

    public func save() throws {
        if context.hasChanges { try context.save() }
    }
}
