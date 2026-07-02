# StarCrew

Образовательное приложение для детей 5–10 лет — космическое приключение. Ребёнок ведёт экипаж корабля «Аврора» по галактике, где планеты — это учебные темы, а миссии — уроки. Двуязычный контент (RU/EN), адаптивная сложность, offline, без рекламы и трекинга.

Статус: **Фаза 0 (каркас)**. Собирается вертикальный срез — движок заданий с одним типом (`multipleChoice`), загрузка контента из JSON, SwiftData-хранилище прогресса, экран миссии.

## Документация

- [STARCREW_DOCS.md](STARCREW_DOCS.md) — концепция, архитектура, правила.
- [01_ANALYSIS.md](01_ANALYSIS.md) — рынок, требования Apple/приватность/доступность.
- [02_TECH.md](02_TECH.md) — реализация, движок, адаптивность.
- [03_PROGRAM.md](03_PROGRAM.md) — педагогика и программа обучения.

## Структура

```
Package.swift            Swift Package с модулями:
Sources/
  StarCrewCore/            домен: движок заданий, типы (без UI/SwiftData)
  StarCrewContent/         загрузка и валидация JSON-контента
  StarCrewPersistence/     SwiftData: схема, прогресс, mastery
  StarCrewEngine/          MissionViewModel (@Observable)
  StarCrewUI/              SwiftUI-вьюхи, реестр рендереров
Tests/                    Swift Testing: домен, контент, персистентность
AppHost/                  @main App + PrivacyInfo (для iOS app target)
```

Домен и контент не зависят от SwiftUI/SwiftData и тестируются на macOS-хосте.

## Сборка и тесты (логика, без симулятора)

```sh
swift build
swift test
```

## Запуск приложения на iPad/симуляторе

Пакет собирает логику и вьюхи, но iOS-приложению нужен app target в Xcode:

1. File → New → Project → App (SwiftUI, iOS), назвать `StarCrew`.
2. Удалить сгенерированные `ContentView.swift` и `<Name>App.swift`.
3. Перетащить эту папку как **local Swift Package** (File → Add Package Dependencies → Add Local) и подключить продукты `StarCrewUI`, `StarCrewEngine`, `StarCrewContent`, `StarCrewPersistence`, `StarCrewCore`.
4. Добавить в target файлы из `AppHost/` (`StarCrewApp.swift`, `PrivacyInfo.xcprivacy`).
5. Target → iPad, минимум iOS 17. Run.

Deployment target: iOS/iPadOS 17+. Инструменты: Xcode 26.x, Swift 6.2.
