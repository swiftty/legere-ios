import SwiftUI
import Domain

extension NovelDetailProvider {
    static var fatal: Self {
        self.init(
            fetchByID: { _ in fatalError() },
            fetchFromRankingItem: { _ in fatalError() }
        )
    }
}

// MARK: -

extension EnvironmentValues {
    private struct Key: EnvironmentKey {
        static var defaultValue: NovelDetailProvider { .fatal }
    }

    public var detailProvider: NovelDetailProvider {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }
}
