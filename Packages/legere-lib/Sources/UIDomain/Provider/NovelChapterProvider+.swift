import SwiftUI
import Domain

extension NovelChapterProvider {
    static var fatal: Self {
        self.init(
            fetch: { _ in fatalError() }
        )
    }
}

// MARK: -

extension EnvironmentValues {
    private struct Key: EnvironmentKey {
        static var defaultValue: NovelChapterProvider { .fatal }
    }

    public var chapterProvider: NovelChapterProvider {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }
}
