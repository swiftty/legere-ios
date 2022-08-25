import SwiftUI
import Domain

public enum Routings {}

// MARK: -
extension Routings {
    public struct ChapterPage: Routing {
        public let id: SourceID
        public let context: Context

        public struct Context: Hashable {
            public let isPresented: Binding<Bool>

            public static func == (lhs: Self, rhs: Self) -> Bool { true }

            public func hash(into hasher: inout Hasher) {
                hasher.combine(ObjectIdentifier(Context.self))
            }
        }
    }
}

extension Routing where Self == Routings.ChapterPage {
    public static func chapterPage(id: SourceID, isPresented: Binding<Bool>) -> Self {
        self.init(id: id, context: .init(isPresented: isPresented))
    }
}

