import SwiftUI
import Domain

extension RankingProvider {
    static var fatal: Self {
        self.init(
            fetchNarouDailyRankings: { fatalError() }
        )
    }
}

// MARK: -

extension EnvironmentValues {
    private struct Key: EnvironmentKey {
        static var defaultValue: RankingProvider { .fatal }
    }

    public var rankingProvider: RankingProvider {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }
}
