import Foundation

public struct NovelDetailProvider {
    struct Props {
        var fetchByID: (SourceID) async throws -> NovelDetail
        var fetchFromRankingItem: (RankingItem) async throws -> NovelDetail
    }

    var props: Props

    public init(
        fetchByID: @escaping (SourceID) async throws -> NovelDetail,
        fetchFromRankingItem: @escaping (RankingItem) async throws -> NovelDetail
    ) {
        props = .init(
            fetchByID: fetchByID,
            fetchFromRankingItem: fetchFromRankingItem
        )
    }

    public func fetch(withID id: SourceID) async throws -> NovelDetail {
        try await props.fetchByID(id)
    }

    public func fetch(from item: RankingItem) async throws -> NovelDetail {
        try await props.fetchFromRankingItem(item)
    }
}
