import Foundation

public struct NovelChapterProvider {
    struct Props {
        var fetch: (SourceID) async throws -> NovelChapter
    }

    var props: Props

    public init(
        fetch: @escaping (SourceID) async throws -> NovelChapter
    ) {
        props = .init(
            fetch: fetch
        )
    }

    public func fetch(withID id: SourceID) async throws -> NovelChapter {
        try await props.fetch(id)
    }
}
