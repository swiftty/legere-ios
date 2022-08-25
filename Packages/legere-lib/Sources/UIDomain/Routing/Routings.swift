import Foundation
import Domain

public enum Routings {}

// MARK: -
extension Routings {
    public struct ChapterPage: Routing {
        public let id: SourceID
    }
}

extension Routing where Self == Routings.ChapterPage {
    public static func chapterPage(id: SourceID) -> Self { self.init(id: id) }
}

