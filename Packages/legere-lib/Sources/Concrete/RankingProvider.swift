import Foundation
import Domain
import NarouKit
import DataCacheKit

extension RankingProvider {
    public static func live(
        session: URLSession
    ) -> Self {
        var options = DiskCache<String>.Options.default(path: .default(name: "rankings"))
        options.expirationTimeout = 24 * 60 * 60
        let cache = DiskCache<String>(options: options)

        return self.init(
            fetchNarouDailyRankings: {
                return try await caching(forKey: "narou:daily", in: cache) {
                    try await [RankingItem].fetch(using: session)
                }
            }
        )
    }
}
