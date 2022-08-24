import Foundation

public struct NovelChapter: Identifiable, Equatable, Codable {
    public var id: SourceID
    public var title: String?
    public var body: AttributedString

    public init(id: SourceID, title: String? = nil, body: AttributedString) {
        self.id = id
        self.title = title
        self.body = body
    }
}
