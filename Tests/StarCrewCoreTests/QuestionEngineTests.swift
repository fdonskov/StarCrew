import Testing
import Foundation
@testable import StarCrewCore

@Suite("Question engine")
struct QuestionEngineTests {
    private func sampleQuestion() -> MultipleChoiceQuestion {
        MultipleChoiceQuestion(
            id: "q1",
            prompt: LocalizedContent(ru: "2 + 3?", en: "2 + 3?"),
            difficulty: 2,
            skillTags: ["add_within_10"],
            options: [
                .init(id: "a", label: LocalizedContent(ru: "4", en: "4")),
                .init(id: "b", label: LocalizedContent(ru: "5", en: "5")),
            ],
            correctOptionID: "b",
            hint: LocalizedContent(ru: "Прибавляй по одному", en: "Add one at a time")
        )
    }

    @Test("Correct choice is graded right")
    func correctChoice() {
        let grade = sampleQuestion().evaluate(.choice("b"))
        #expect(grade.isCorrect)
        #expect(grade.partialScore == 1)
        #expect(grade.feedback == nil)
    }

    @Test("Wrong choice returns the hint")
    func wrongChoice() {
        let grade = sampleQuestion().evaluate(.choice("a"))
        #expect(!grade.isCorrect)
        #expect(grade.partialScore == 0)
        #expect(grade.feedback?.ru == "Прибавляй по одному")
    }

    @Test("Wrong answer type does not count")
    func wrongAnswerType() {
        #expect(sampleQuestion().evaluate(.text("5")).isCorrect == false)
    }

    @Test("selfCheck catches a broken correctOptionID")
    func selfCheckCatchesBadCorrectID() {
        let bad = MultipleChoiceQuestion(
            id: "bad",
            prompt: LocalizedContent(ru: "x", en: "x"),
            difficulty: 1,
            skillTags: ["t"],
            options: [
                .init(id: "a", label: LocalizedContent(ru: "1", en: "1")),
                .init(id: "b", label: LocalizedContent(ru: "2", en: "2")),
            ],
            correctOptionID: "z"
        )
        #expect(throws: ContentError.self) { try bad.selfCheck() }
    }

    @Test("Registry decodes multipleChoice by the type field")
    func registryDecodesByType() throws {
        let json = """
        {
          "type": "multipleChoice",
          "id": "q_decode",
          "prompt": { "ru": "Цвет неба?", "en": "Sky color?" },
          "difficulty": 1,
          "skillTags": ["colors"],
          "options": [
            { "id": "a", "label": { "ru": "синий", "en": "blue" } },
            { "id": "b", "label": { "ru": "зелёный", "en": "green" } }
          ],
          "correctOptionID": "a"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.userInfo[.questionRegistry] = QuestionRegistry.standard
        let question = try decoder.decode(AnyQuestion.self, from: json)

        #expect(question.kind == .multipleChoice)
        #expect(question.id == "q_decode")
        #expect(question.prompt.en == "Sky color?")
        #expect(question.evaluate(.choice("a")).isCorrect)
    }

    @Test("Unknown task type is a decoding error")
    func unknownKindThrows() {
        let json = """
        { "type": "hologram", "id": "q", "prompt": { "ru": "x", "en": "x" },
          "difficulty": 1, "skillTags": ["t"] }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.userInfo[.questionRegistry] = QuestionRegistry.standard
        #expect(throws: ContentError.self) { try decoder.decode(AnyQuestion.self, from: json) }
    }

    @Test("Missing registry in userInfo is an error")
    func missingRegistryThrows() {
        let json = """
        { "type": "multipleChoice", "id": "q", "prompt": { "ru": "x", "en": "x" },
          "difficulty": 1, "skillTags": ["t"],
          "options": [ { "id": "a", "label": { "ru": "1", "en": "1" } } ],
          "correctOptionID": "a" }
        """.data(using: .utf8)!
        #expect(throws: ContentError.self) { try JSONDecoder().decode(AnyQuestion.self, from: json) }
    }
}

@Suite("Localization")
struct LocalizationTests {
    @Test("Text is selected by language")
    func textByLanguage() {
        let content = LocalizedContent(ru: "Привет", en: "Hello")
        #expect(content.text(for: .ru) == "Привет")
        #expect(content.text(for: .en) == "Hello")
    }
}
