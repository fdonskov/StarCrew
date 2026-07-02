import Testing
import Foundation
import SwiftData
@testable import StarCrewPersistence
import StarCrewCore

@Suite("Persistence & progress")
@MainActor
struct ProgressServiceTests {
    private func makeContext() throws -> ModelContext {
        ModelContext(try PersistenceController.makeInMemoryContainer())
    }

    private func question(id: String, tag: SkillTag) -> AnyQuestion {
        AnyQuestion(MultipleChoiceQuestion(
            id: id,
            prompt: LocalizedContent(ru: "?", en: "?"),
            difficulty: 1,
            skillTags: [tag],
            options: [
                .init(id: "a", label: LocalizedContent(ru: "1", en: "1")),
                .init(id: "b", label: LocalizedContent(ru: "2", en: "2")),
            ],
            correctOptionID: "a"
        ))
    }

    @Test("In-memory container builds")
    func containerBuilds() throws {
        _ = try makeContext()
    }

    @Test("Correct answer raises mastery, attempts count grows")
    func correctRaisesMastery() throws {
        let context = try makeContext()
        let learner = Learner(displayName: "Аля", gradeLevel: 1, createdAt: .distantPast)
        context.insert(learner)
        let service = ProgressService(context: context, alpha: 0.3)

        service.record(question: question(id: "q1", tag: "count_to_10"), grade: .correct, for: learner)
        let progress = try #require(learner.skills.first { $0.skillTag == "count_to_10" })
        #expect(progress.attempts == 1)
        #expect(abs(progress.mastery - 0.3) < 0.0001)   // 0.7*0 + 0.3*1

        service.record(question: question(id: "q2", tag: "count_to_10"), grade: .correct, for: learner)
        #expect(progress.attempts == 2)
        #expect(progress.mastery > 0.3)                 // grows toward 1
    }

    @Test("Wrong answer pulls mastery down")
    func wrongLowersMastery() throws {
        let context = try makeContext()
        let learner = Learner(displayName: "Бо", gradeLevel: 1, createdAt: .distantPast)
        context.insert(learner)
        let service = ProgressService(context: context, alpha: 0.5)

        let q = question(id: "q", tag: "add_within_10")
        service.record(question: q, grade: .correct, for: learner)   // 0.5
        service.record(question: q, grade: .wrong, for: learner)     // 0.25
        let progress = try #require(learner.skills.first { $0.skillTag == "add_within_10" })
        #expect(abs(progress.mastery - 0.25) < 0.0001)
        try service.save()
    }
}
