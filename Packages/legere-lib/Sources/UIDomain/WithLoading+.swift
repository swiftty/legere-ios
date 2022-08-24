import SwiftUI
import Domain

extension State {
    public func `try`<T>(_ f: () async throws -> T) async where Value == WithLoading<T> {
        do {
            wrappedValue.next(.loading)
            wrappedValue.wrappedValue = try await f()
        } catch {
            wrappedValue.next(.failed(error))
        }
    }
}
