import Foundation
import SwiftData

/// Versioned schema from the first release, so the first change is not painful
/// (see 02_TECH.md §3.3).
public enum SchemaV1: VersionedSchema {
    public static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }
    public static var models: [any PersistentModel.Type] {
        [Learner.self, SkillProgress.self, ReviewItem.self]
    }
}

public enum StarCrewMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] { [SchemaV1.self] }
    public static var stages: [MigrationStage] { [] }
}

public enum PersistenceController {
    /// App container (data on disk).
    public static func makeContainer() throws -> ModelContainer {
        try ModelContainer(
            for: Schema(versionedSchema: SchemaV1.self),
            migrationPlan: StarCrewMigrationPlan.self
        )
    }

    /// In-memory container for tests and previews.
    public static func makeInMemoryContainer() throws -> ModelContainer {
        try ModelContainer(
            for: Schema(versionedSchema: SchemaV1.self),
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }
}
