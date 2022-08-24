import Foundation

public struct NovelDetailProvider {
    struct Props {
        var fetch: (SourceID) async throws -> NovelDetail
    }

    var props: Props

    public init(
        fetch: @escaping (SourceID) async throws -> NovelDetail
    ) {
        props = .init(
            fetch: fetch
        )
    }

    public func fetch(withID id: SourceID) async throws -> NovelDetail {
        try await props.fetch(id)
    }
}
