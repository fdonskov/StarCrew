import Foundation

/// Content language. Switched inside the app independently of the system locale
/// (see 02_TECH.md §6). Russian is the base language.
public enum AppLanguage: String, Codable, Sendable, CaseIterable {
    case ru
    case en

    public var localeIdentifier: String {
        switch self {
        case .ru: return "ru-RU"
        case .en: return "en-US"
        }
    }
}

/// Bilingual text. Task strings are content, not UI strings, so they live in the
/// data rather than in a String Catalog (see 02_TECH.md §2).
public struct LocalizedContent: Codable, Hashable, Sendable {
    public let ru: String
    public let en: String

    public init(ru: String, en: String) {
        self.ru = ru
        self.en = en
    }

    public func text(for language: AppLanguage) -> String {
        switch language {
        case .ru: return ru
        case .en: return en
        }
    }
}
