import Foundation
import Domain
import NarouKit
import DataCacheKit

extension NovelDetailProvider {
    public static func live(
        session: URLSession
    ) -> Self {
        var options = DiskCache<String>.Options.default(path: .default(name: "novels"))
        options.expirationTimeout = 60 * 60
        let cache = DiskCache<String>(options: options)

        return self.init(
            fetch: { id in
                switch id {
                case .narou(let code):
                    return try await caching(forKey: code.rawValue, in: cache) {
                        try await NovelDetail.fetch(withCode: code, using: session)
                    }
                }
            }
        )
    }
}
