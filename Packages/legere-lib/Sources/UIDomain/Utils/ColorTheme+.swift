import Domain
import UIKit

extension ColorTheme {
    public var textColor: UIColor {
        value.asColor(for: .text)
    }

    public var backgroundColor: UIColor {
        value.asColor(for: .background)
    }
}

private extension ColorTheme.Value {
    enum Variant {
        case text, background
    }

    func asColor(for variant: Variant) -> UIColor {
        switch (self, variant) {
        case (.system, .text):
            return .label

        case (.system, .background):
            return .systemBackground

        case (.mild, .text):
            lazy var light = UIColor(hex: "292826") ?? .label
            lazy var dark = UIColor(hex: "DFDFE0") ?? .label
            return UIColor { trait in
                trait.userInterfaceStyle == .light ? light : dark
            }

        case (.mild, .background):
            lazy var light = UIColor(hex: "F6F5EB") ?? .systemBackground
            lazy var dark = UIColor(hex: "292A2F") ?? .systemBackground
            return UIColor { trait in
                trait.userInterfaceStyle == .light ? light : dark
            }
        }
    }
}

private extension UIColor {
    convenience init?(hex string: String) {
        guard string.count == 6 else { return nil }

        func range(at offset: Int) -> Range<String.Index> {
            string.index(string.startIndex, offsetBy: offset)..<string.index(string.startIndex, offsetBy: offset + 2)
        }
        func float(_ v: Int) -> CGFloat {
            CGFloat(v) / 255
        }

        guard let r = Int(string[range(at: 0)], radix: 16),
              let g = Int(string[range(at: 2)], radix: 16),
              let b = Int(string[range(at: 4)], radix: 16) else { return nil }

        self.init(red: float(r), green: float(g), blue: float(b), alpha: 1)
    }
}
