import Foundation
import CoreText
import Domain
import JapaneseAttributesKit
import SwiftSoup

extension NovelChapter {
    public static func load(fromHTML html: Data) throws -> Self {
        try self.load(fromHTML: String(data: html, encoding: .utf8) ?? "")
    }

    public static func load(fromHTML html: String) throws -> Self {
        let html = try SwiftSoup.parse(html)

        return try self.init(
            id: parseSourceID(html),
            title: parseTitle(html),
            body: try attributedString(from: parseHonbun(html))
        )
    }

    enum BodyBlock: Equatable {
        case body(String)
        case ruby(String, body: String)
        case br
    }
}

extension NovelChapter {
    // MARK: -
    static func parseTitle(_ html: String) throws -> String? {
        let html = try SwiftSoup.parse(html)
        return try parseTitle(html)
    }

    private static func parseTitle(_ html: Document) throws -> String? {
        try html.select("#novel_contents .novel_subtitle").first()?.text()
    }


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
    static func parseHonbun(_ html: String) throws -> [NovelChapter.BodyBlock] {
        let html = try SwiftSoup.parse(html)
        return try parseHonbun(html)
    }

    private static func parseHonbun(_ html: Document) throws -> [NovelChapter.BodyBlock] {
        guard let honbun = try html.getElementById("novel_honbun") else {
            throw NarouKitError.invalidHTML(html)
        }

        var result: [NovelChapter.BodyBlock] = []

        for e in honbun.children() {
            for n in e.getChildNodes() {
                switch n {
                case let n as TextNode:
                    result.append(.body(n.text().trimmingCharacters(in: .whitespaces)))

                case let n as Element:
                    // ruby or br
                    switch n.tagName() {
                    case "br":
                        result.append(.br)

                    case "ruby":
                        let body = try n.getElementsByTag("rb").text()
                        let furigana = try n.getElementsByTag("rt").text()
                        result.append(.ruby(furigana, body: body))

                    default:
                        result.append(.body(try n.text().trimmingCharacters(in: .whitespaces)))
                    }

                default:
                    throw NarouKitError.invalidHTML(html)
                }
            }
            result.append(.br)
        }

        return result
    }

    // MARK: -
    static func attributedString(from blocks: [BodyBlock]) -> AttributedString {
        var body = AttributedString()
        for block in blocks {
            switch block {
            case .body(let string):
                body += AttributedString(string)
            case .ruby(let ruby, let string):
                var text = AttributedString(string)
                text.ruby = .init(text: ruby)
                body += text
            case .br:
                body += "\n"
            }
        }
        return body
    }
}
