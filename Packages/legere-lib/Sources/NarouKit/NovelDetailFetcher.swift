import Foundation
import Domain

extension NovelDetail {
    public static func fetch(withCode code: SourceID.NCode, using session: URLSession) async throws -> Self {
        let url = URL(string: "https://ncode.syosetu.com/\(code.rawValue)/")!
        let (data, _) = try await session.data(from: url)
        do {
            return try self.load(fromHTML: data)
        } catch NarouKitError.invalidHTML {
            let chapter = try NovelChapter.load(fromHTML: data)
            return self.init(
                id: .narou(code),
                title: chapter.title ?? "",
                auther: .init(id: .narou(""), name: ""),
                index: [
                    .init(id: chapter.id, title: chapter.title)
                ]
            )
        }
    }

    public static func fetch(from item: RankingItem, using session: URLSession) async throws -> Self {
        guard case .narou(let code) = item.id else { fatalError() }
        let url = URL(string: "https://ncode.syosetu.com/\(code.rawValue)/")!
        let (data, _) = try await session.data(from: url)
        do {
            return try self.load(fromHTML: data)
        } catch NarouKitError.invalidHTML {
            let chapter = try NovelChapter.load(fromHTML: data)
            return self.init(
                id: item.id,
                title: item.title,
                story: item.story,
                auther: item.auther,
                index: [
                    .init(id: chapter.id, title: chapter.title ?? item.title)
                ]
            )
        }
    }
}
