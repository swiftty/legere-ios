import Foundation
import Domain

extension [RankingItem] {
    public static func fetch(using session: URLSession) async throws -> Self {
        let url = URL(string: "https://yomou.syosetu.com/rank/list/type/daily_total/")!
        let (data, _) = try await session.data(from: url)
        return try self.load(fromHTML: data)
    }
}
