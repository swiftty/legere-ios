import Domain
import UIKit

extension ColorTheme {
    public var textColor: UIColor { text.asColor(or: .label) }
    public var backgroundColor: UIColor { background.asColor(or: .systemBackground) }
}

private extension ColorTheme.Value {
    func asColor(or `default`: @autoclosure () -> UIColor) -> UIColor {
        switch self {
        case .hex(let string):
            return UIColor(hex: string) ?? `default`()

        case .system:
            return `default`()
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
