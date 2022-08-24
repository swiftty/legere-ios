import Foundation

public struct RankingProvider {
    struct Props {
        var fetchNarouDailyRankings: () async throws -> [RankingItem]
    }

    var props: Props

    public init(
        fetchNarouDailyRankings: @escaping () async throws -> [RankingItem]
    ) {
        props = .init(
            fetchNarouDailyRankings: fetchNarouDailyRankings
        )
    }

    public func fetchNarouDailyRankings() async throws -> [RankingItem] {
        try await props.fetchNarouDailyRankings()
    }
}
