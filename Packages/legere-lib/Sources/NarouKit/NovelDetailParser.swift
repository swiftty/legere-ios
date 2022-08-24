import Foundation
import SwiftSoup
import Domain

extension NovelDetail {
    public static func load(fromHTML html: Data) throws -> Self {
        try self.load(fromHTML: String(data: html, encoding: .utf8) ?? "")
    }

    public static func load(fromHTML html: String) throws -> Self {
        let html = try SwiftSoup.parse(html)

        return try self.init(
            id: parseSourceID(html),
            title: parseTitle(html),
            auther: parseAuther(html),
            index: parseIndex(html)
        )
    }
}

extension NovelDetail {
    // MARK: -
    static func parseSourceID(_ html: String) throws -> SourceID {
        let html = try SwiftSoup.parse(html)
        return try parseSourceID(html)
    }

    private static func parseSourceID(_ html: Document) throws -> SourceID {
        guard let meta = try html.select("meta[property=og:url]").first() else {
            throw NarouKitError.invalidHTML(html)
        }
        guard let content = URL(string: try meta.attr("content")) else {
            throw NarouKitError.invalidHTML(html)
        }
        return .narou(content.path().trimmingCharacters(in: .init(charactersIn: "/")))
    }

    // MARK: -
    static func parseTitle(_ html: String) throws -> String {
        let html = try SwiftSoup.parse(html)
        return try parseTitle(html)
    }

    private static func parseTitle(_ html: Document) throws -> String {
        guard let text = try html.select("#novel_contents .novel_title").first()?.text() else {
            throw NarouKitError.invalidHTML(html)
        }
        return text
    }

    // MARK: -
    static func parseStory(_ html: String) throws -> String? {
        let html = try SwiftSoup.parse(html)
        return try parseStory(html)
    }

    private static func parseStory(_ html: Document) throws -> String? {
        guard let nodes = try html.getElementById("novel_ex")?.getChildNodes() else { return nil }
        return nodes
            .compactMap { n in
                switch n {
                case let n as TextNode: return n.text().trimmingCharacters(in: .whitespaces)
                case let n as Element where n.tagName() == "br": return "\n"
                default: return nil
                }
            }
            .joined()
    }

    // MARK: -
    static func parseAuther(_ html: String) throws -> Auther {
        let html = try SwiftSoup.parse(html)
        return try parseAuther(html)
    }

    private static func parseAuther(_ html: Document) throws -> Auther {
        guard let e = try html.select("#novel_contents .novel_writername").first(),
              let a = try e.getElementsByTag("a").first(),
              let href = URL(string: try a.attr("href")) else {
            throw NarouKitError.invalidHTML(html)
        }
        let inner = try a.text()
        return Auther(
            id: .narou(href.path().trimmingCharacters(in: .init(charactersIn: "/"))),
            name: inner
        )
    }

    // MARK: -
    static func parseIndex(_ html: String) throws -> [NovelDetail.Index] {
        let html = try SwiftSoup.parse(html)
        return try parseIndex(html)
    }

    private static func parseIndex(_ html: Document) throws -> [NovelDetail.Index] {
        guard let e = try html.getElementsByClass("index_box").first() else {
            throw NarouKitError.invalidHTML(html)
        }

        var index: [NovelDetail.Index] = []

        for a in try e.select(".subtitle a") {
            let href = try a.attr("href").trimmingCharacters(in: .init(charactersIn: "/"))
            let inner = try a.text()
            index.append(.init(id: .narou(href), title: inner))
        }

        return index
    }
}
