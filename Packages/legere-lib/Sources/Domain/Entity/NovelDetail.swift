import Foundation

public enum SourceID: Hashable, Codable {
    case narou(NCode)

    public static func narou(_ rawValue: String) -> Self {
        return .narou(NCode(rawValue: rawValue))
    }

    public struct NCode: Hashable, RawRepresentable, Codable {
        public var rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

public struct NovelDetail: Identifiable, Equatable, Codable {
    public var id: SourceID
    public var title: String
    public var story: String?
    public var auther: Auther
    public var index: [Index]

    public struct Index: Identifiable, Equatable, Codable {
        public var id: SourceID
        public var title: String?

        public init(id: SourceID, title: String? = nil) {
            self.id = id
            self.title = title
        }
    }

    public init(id: SourceID, title: String, story: String? = nil, auther: Auther, index: [Index]) {
        self.id = id
        self.title = title
        self.story = story
        self.auther = auther
        self.index = index
    }
}

public struct Auther: Identifiable, Equatable, Hashable, Codable {
    public var id: SourceID
    public var name: String

    public init(id: SourceID, name: String) {
        self.id = id
        self.name = name
    }
}
