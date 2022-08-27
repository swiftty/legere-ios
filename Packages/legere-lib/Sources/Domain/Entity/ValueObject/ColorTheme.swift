import Foundation

public struct ColorTheme: Hashable, Codable {
    public enum Value: Hashable, Codable {
        case hex(String)
        case system
    }

    public var name: String
    public var text: Value
    public var background: Value
}

extension ColorTheme {
    public static var system: Self {
        .init(name: "system", text: .system, background: .system)
    }

    public static var systemLight: Self {
        .init(name: "systemLight", text: .hex("000000"), background: .hex("FEFEFE"))
    }

    public static var systemDark: Self {
        .init(name: "systemDark", text: .hex("FEFEFE"), background: .hex("000000"))
    }

    public static var sepia: Self {
        .init(name: "sepia", text: .hex("292826"), background: .hex("F6F5EB"))
    }

    public static var monotone: Self {
        .init(name: "monotone", text: .hex("DFDFE0"), background: .hex("292A2F"))
    }
}

extension ColorTheme {
    public static var allThemes: [Self] {
        [.system, .systemLight, .systemDark, .sepia, .monotone]
    }
}
