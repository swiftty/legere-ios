import Foundation
import Domain
import SwiftSoup

enum NarouKitError: Error {
    case invalidHTML(String)
}

extension NarouKitError {
    static func invalidHTML(_ html: Document) -> Self {
        .invalidHTML((try? html.html()) ?? "")
    }
}
