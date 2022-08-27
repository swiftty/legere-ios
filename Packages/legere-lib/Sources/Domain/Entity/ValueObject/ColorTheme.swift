import Foundation

public struct ColorTheme: Hashable, Codable {
    public enum Value: Hashable, Codable {
        case system, mild
    }

    public var name: String
    public var value: Value
}

extension ColorTheme {
    public static var system: Self {
        .init(name: "system", value: .system)
    }
    public static var mild: Self {
        .init(name: "mild", value: .mild)
    }
}

extension ColorTheme {
    public static var allThemes: [Self] {
        [.system, .mild]
    }
}
