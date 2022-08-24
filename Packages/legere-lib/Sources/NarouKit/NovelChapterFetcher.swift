import Foundation
import Domain

extension NovelChapter {
    public static func fetch(withCode code: SourceID.NCode, using session: URLSession) async throws -> Self {
        let url = URL(string: "https://ncode.syosetu.com/\(code.rawValue)/")!
        let (data, _) = try await session.data(from: url)
        return try self.load(fromHTML: data)
    }
}
