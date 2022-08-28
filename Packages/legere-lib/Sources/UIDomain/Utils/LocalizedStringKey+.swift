import SwiftUI

extension LocalizedStringKey.StringInterpolation {
    public mutating func appendInterpolation<T>(dump: T) {
        appendInterpolation(String(describing: dump))
    }
}
