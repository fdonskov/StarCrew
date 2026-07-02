import SwiftUI
import SwiftData
import StarCrewCore
import StarCrewContent
import StarCrewEngine
import StarCrewPersistence
import StarCrewUI

// iOS/iPadOS app entry point. Thin shell over the StarCrew package modules.
// Added to the iOS app target (see AppHost/README.md). Phase 0 skeleton:
// one task type (multipleChoice) end-to-end + SwiftData + progress recording.
@main
struct StarCrewApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try PersistenceController.makeContainer()
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(container)
        }
    }
}

private struct RootView: View {
    @Environment(\.modelContext) private var context
    @AppStorage("contentLanguage") private var languageRaw = AppLanguage.ru.rawValue

    var body: some View {
        if let mission = Self.firstMission {
            MissionView(
                model: makeModel(for: mission),
                registry: .standard,
                language: AppLanguage(rawValue: languageRaw) ?? .ru
            )
        } else {
            ContentUnavailableView("Нет контента", systemImage: "shippingbox")
        }
    }

    private func makeModel(for mission: MissionContent) -> MissionViewModel {
        let service = ProgressService(context: context)
        let learner = Self.currentLearner(in: context)
        return MissionViewModel(mission: mission) { question, grade in
            service.record(question: question, grade: grade, for: learner)
            try? service.save()
        }
    }

    private static var firstMission: MissionContent? {
        (try? ContentLoader.loadAllBundledPacks())?.first?.planet.missions.first
    }

    private static func currentLearner(in context: ModelContext) -> Learner {
        if let existing = try? context.fetch(FetchDescriptor<Learner>()).first {
            return existing
        }
        let learner = Learner(displayName: "Командир", gradeLevel: 1, createdAt: .now)
        context.insert(learner)
        return learner
    }
}
