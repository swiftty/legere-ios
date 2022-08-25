import Foundation

extension AttributeScopes {
    public struct JapaneseAttributes: AttributeScope {
        public let ruby: RubyAttribute

        public let foundation: FoundationAttributes
        #if canImport(UIKit)
        public let uiKit: UIKitAttributes
        #endif
        #if canImport(SwiftUI)
        public let swiftUI: SwiftUIAttributes
        #endif
    }

    public var japanese: JapaneseAttributes.Type { JapaneseAttributes.self }
}

extension AttributeDynamicLookup {
    public subscript<T: AttributedStringKey>(dynamicMember keyPath: KeyPath<AttributeScopes.JapaneseAttributes, T>) -> T {
        return self[T.self]
    }
}
