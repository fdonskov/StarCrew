import Foundation
import StarCrewCore

/// Loads and validates content from JSON packs in the bundle.
public enum ContentLoader {
    public static let currentSchemaVersion = 1

    public static func decoder(registry: QuestionRegistry = .standard) -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.userInfo[.questionRegistry] = registry
        return decoder
    }

    public static func loadPack(at url: URL, registry: QuestionRegistry = .standard) throws -> ContentPack {
        let data = try Data(contentsOf: url)
        return try decoder(registry: registry).decode(ContentPack.self, from: data)
    }

    /// URLs of all content JSON packs in the module bundle.
    /// `.process` flattens the folder structure, so we search the bundle resource root.
    public static func bundledPackURLs() -> [URL] {
        Bundle.module.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? []
    }

    public static func loadAllBundledPacks(registry: QuestionRegistry = .standard) throws -> [ContentPack] {
        try bundledPackURLs().map { try loadPack(at: $0, registry: registry) }
    }

    /// Validates a single pack: schema version, id uniqueness, presence of
    /// translations, task domain invariants. Used as a test gate (see 02_TECH.md §2).
    public static func validate(_ pack: ContentPack) throws {
        if pack.contentSchemaVersion != currentSchemaVersion {
            throw ContentError.invalidQuestion(
                id: pack.planet.id,
                reason: "contentSchemaVersion \(pack.contentSchemaVersion) != \(currentSchemaVersion)"
            )
        }
        var seenQuestionIDs = Set<String>()
        for mission in pack.planet.missions {
            for question in mission.questions {
                if question.prompt.ru.isEmpty {
                    throw ContentError.invalidQuestion(id: question.id, reason: "empty RU prompt translation")
                }
                if question.prompt.en.isEmpty {
                    throw ContentError.invalidQuestion(id: question.id, reason: "empty EN prompt translation")
                }
                if question.skillTags.isEmpty {
                    throw ContentError.invalidQuestion(id: question.id, reason: "no skillTags — breaks adaptivity")
                }
                if !seenQuestionIDs.insert(question.id).inserted {
                    throw ContentError.invalidQuestion(id: question.id, reason: "duplicate question id")
                }
                try question.selfCheck()
            }
        }
    }
}
