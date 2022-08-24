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

extension NovelChapterProvider {
    static var fatal: Self {
        self.init(
            fetch: { _ in fatalError() }
        )
    }
}

// MARK: -
import SwiftUI

extension EnvironmentValues {
    private struct Key: EnvironmentKey {
        static var defaultValue: NovelChapterProvider { .fatal }
    }

    public var chapterProvider: NovelChapterProvider {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }
}
