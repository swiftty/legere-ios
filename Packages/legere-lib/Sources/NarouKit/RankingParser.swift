import Foundation
import SwiftSoup
import Domain

extension [RankingItem] {
    public static func load(fromHTML html: Data) throws -> Self {
        try self.load(fromHTML: String(data: html, encoding: .utf8) ?? "")
    }

    public static func load(fromHTML html: String) throws -> Self {
        let html = try SwiftSoup.parse(html)

        var result: Self = []
        for item in try html.getElementsByClass("ranking_list") {
            guard let item = try RankingItem.parse(item) else {
                throw NarouKitError.invalidHTML(html)
            }
            result.append(item)
        }

        return result
    }
}

extension RankingItem {
    static func parse(_ html: String) throws -> Self? {
        let html = try SwiftSoup.parse(html)
        return try parse(html)
    }

    fileprivate static func parse(_ html: Element) throws -> Self? {
        guard let title = try html.select(".rank_h a").first(),
              let table = try html.getElementsByClass("rank_table").first(),
              let story = try table.select(".ex").first()?.text(),
              let auther = try parseAuther(table.select(".h_info a").last()),
              let id = try parseSourceID(title) else {
            return nil
        }

        return try self.init(
            id: id,
            title: title.text(),
            story: story,
            auther: auther
        )
    }

    // MARK: -
    private static func parseSourceID(_ a: Element) throws -> SourceID? {
        guard let href = URL(string: try a.attr("href")) else { return nil }
        return .narou(href.path().trimmingCharacters(in: .init(charactersIn: "/")))
    }

    private static func parseAuther(_ a: Element?) throws -> Auther? {
        guard let a, let href = URL(string: try a.attr("href")) else { return nil }

        let inner = try a.text()

        return Auther(
            id: .narou(href.path().trimmingCharacters(in: .init(charactersIn: "/"))),
            name: inner
        )
    }
}
