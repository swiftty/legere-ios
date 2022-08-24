import Foundation
import Domain
import NarouKit
import DataCacheKit

extension NovelChapterProvider {
    public static func live(
        session: URLSession
    ) -> Self {
        var options = DiskCache<String>.Options.default(path: .default(name: "chapters"))
        options.expirationTimeout = 24 * 60 * 60
        let cache = DiskCache<String>(options: options)

        return self.init(
            fetch: { id in
                switch id {
                case .narou(let code):
                    return try await caching(forKey: code.rawValue, in: cache) {
                        try await NovelChapter.fetch(withCode: code, using: session)
                    }
                }
            }
        )
    }
}
