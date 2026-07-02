import Foundation
import SwiftData

// SwiftData stores only mutable state: progress, mastery, review schedule.
// Content lives in JSON and is linked by string ids (see 02_TECH.md §3.2).

@Model
public final class Learner {
    @Attribute(.unique) public var id: UUID
    public var displayName: String
    public var gradeLevel: Int
    public var suitColorHex: String
    public var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \SkillProgress.learner)
    public var skills: [SkillProgress] = []

    @Relationship(deleteRule: .cascade, inverse: \ReviewItem.learner)
    public var reviewItems: [ReviewItem] = []

    public init(id: UUID = UUID(), displayName: String, gradeLevel: Int, suitColorHex: String = "#3B82F6", createdAt: Date) {
        self.id = id
        self.displayName = displayName
        self.gradeLevel = gradeLevel
        self.suitColorHex = suitColorHex
        self.createdAt = createdAt
    }
}

@Model
public final class SkillProgress {
    public var skillTag: String   // link to content by string
    public var mastery: Double    // 0...1, EWMA of correctness (see 02_TECH.md §4)
    public var attempts: Int
    public var learner: Learner?

    public init(skillTag: String, mastery: Double = 0, attempts: Int = 0) {
        self.skillTag = skillTag
        self.mastery = mastery
        self.attempts = attempts
    }
}

@Model
public final class ReviewItem {
    public var questionID: String   // link to content by string, not an FK
    public var repetition: Int
    public var easeFactor: Double
    public var intervalDays: Double
    public var dueDate: Date        // denormalized for "what to show today"
    public var lastReviewed: Date?
    public var learner: Learner?

    public init(questionID: String, repetition: Int = 0, easeFactor: Double = 2.5, intervalDays: Double = 0, dueDate: Date) {
        self.questionID = questionID
        self.repetition = repetition
        self.easeFactor = easeFactor
        self.intervalDays = intervalDays
        self.dueDate = dueDate
    }
}
