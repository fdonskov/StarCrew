import Testing
import Foundation
@testable import StarCrewContent
import StarCrewCore

@Suite("Content validation")
struct ContentValidationTests {
    @Test("Bundle has at least one content pack")
    func bundleHasPacks() {
        #expect(!ContentLoader.bundledPackURLs().isEmpty)
    }

    @Test("Every pack decodes and passes validation", arguments: ContentLoader.bundledPackURLs())
    func validatePack(_ url: URL) throws {
        let pack = try ContentLoader.loadPack(at: url)
        try ContentLoader.validate(pack)
    }

    @Test("Numeria pack loads correctly")
    func numeriaLoads() throws {
        let packs = try ContentLoader.loadAllBundledPacks()
        let numeria = try #require(packs.first { $0.planet.id == "orion_numeria" })
        #expect(numeria.planet.subject == .math)
        #expect(numeria.planet.sector == 1)
        let mission = try #require(numeria.planet.missions.first)
        #expect(mission.questions.count == 4)
        #expect(mission.passingThreshold == 0.75)
        // First question: 3 stars -> option "b"
        let q = mission.questions[0]
        #expect(q.evaluate(.choice("b")).isCorrect)
        #expect(q.evaluate(.choice("a")).isCorrect == false)
    }

    @Test("Validator rejects an empty EN translation")
    func rejectsMissingTranslation() throws {
        let json = """
        {
          "contentSchemaVersion": 1,
          "planet": {
            "id": "p", "name": { "ru": "П", "en": "P" }, "subject": "math", "sector": 1,
            "missions": [ { "id": "m", "crewMemberID": "leo", "passingThreshold": 0.75, "questions": [
              { "type": "multipleChoice", "id": "bad", "prompt": { "ru": "тест", "en": "" },
                "difficulty": 1, "skillTags": ["t"],
                "options": [ { "id": "a", "label": { "ru": "1", "en": "1" } },
                             { "id": "b", "label": { "ru": "2", "en": "2" } } ],
                "correctOptionID": "a" }
            ] } ]
          }
        }
        """.data(using: .utf8)!
        let pack = try ContentLoader.decoder().decode(ContentPack.self, from: json)
        #expect(throws: ContentError.self) { try ContentLoader.validate(pack) }
    }
}
