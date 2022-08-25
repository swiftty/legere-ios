import Foundation

public enum VerticalGlyphFormAttribute: CodableAttributedStringKey,
                                        MarkdownDecodableAttributedStringKey {
    public static var name: String { NSAttributedString.Key.verticalGlyphForm.rawValue }
    public static var markdownName: String { "vertical" }

    public typealias Value = Bool
}
