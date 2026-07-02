import Foundation
import Observation
import StarCrewCore
import StarCrewContent

/// Drives a mission: one task at a time, scores the result, no-fail (retry after
/// a wrong answer). See 03_PROGRAM.md §B5.
///
/// Recording the result into progress is delegated out via `onRecord` so the
/// Engine stays independent of SwiftData (see 02_TECH.md §1.1).
@MainActor
@Observable
public final class MissionViewModel {
    public let missionID: String
    public let passingThreshold: Double
    private let questions: [AnyQuestion]
    private let onRecord: (@MainActor (AnyQuestion, Grade) -> Void)?

    public private(set) var index = 0
    public private(set) var correctCount = 0
    public private(set) var attemptsOnCurrent = 0
    public private(set) var lastGrade: Grade?
    public private(set) var isFinished = false

    public init(
        mission: MissionContent,
        onRecord: (@MainActor (AnyQuestion, Grade) -> Void)? = nil
    ) {
        self.missionID = mission.id
        self.passingThreshold = mission.passingThreshold
        self.questions = mission.questions
        self.onRecord = onRecord
    }

    public var current: AnyQuestion? {
        index < questions.count ? questions[index] : nil
    }

    public var total: Int { questions.count }
    public var progress: Double { total == 0 ? 0 : Double(index) / Double(total) }

    /// Evaluates an answer. The first correct attempt counts toward the score;
    /// after a wrong answer the task can be retried (no fail state).
    @discardableResult
    public func submit(_ answer: AnyAnswer) -> Grade {
        guard let question = current else { return .wrong }
        let grade = question.evaluate(answer)
        lastGrade = grade
        attemptsOnCurrent += 1
        if grade.isCorrect {
            if attemptsOnCurrent == 1 { correctCount += 1 }
            onRecord?(question, grade)
        }
        return grade
    }

    /// Move to the next task (after a correct answer or showing the hint).
    public func advance() {
        guard !isFinished else { return }
        index += 1
        attemptsOnCurrent = 0
        lastGrade = nil
        if index >= questions.count { isFinished = true }
    }

    public var score: Double {
        total == 0 ? 0 : Double(correctCount) / Double(total)
    }

    public var passed: Bool { score >= passingThreshold }
}
