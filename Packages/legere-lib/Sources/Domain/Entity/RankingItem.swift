import Foundation

public struct RankingItem: Identifiable, Equatable, Codable {
    public var id: SourceID
    public var title: String
    public var story: String?
    public var auther: Auther

    public init(id: SourceID, title: String, story: String? = nil, auther: Auther) {
        self.id = id
        self.title = title
        self.story = story
        self.auther = auther
    }
}
