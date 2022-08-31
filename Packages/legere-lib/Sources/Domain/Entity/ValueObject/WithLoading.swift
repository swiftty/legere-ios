import Foundation

@propertyWrapper
public struct WithLoading<T> {
    public enum State {
        case idle
        case loading
        case loaded(T)
        case failed(Error)
    }
    public var wrappedValue: T {
        get {
            if case .loaded(let val) = currentState {
                return val
            }
            if case .loaded(let val) = oldState {
                return val
            }
            return initialValue
        }
        set {
            next(.loaded(newValue))
        }
    }
    public var projectedValue: Self {
        get { self }
        set { self = newValue }
    }
    public var isLoading: Bool {
        guard case .loading = currentState else { return false }
        return true
    }
    public var error: Error? {
        guard case .failed(let error) = currentState else { return nil }
        return error
    }

    private var currentState: State = .idle {
        didSet {
            switch (oldValue, oldState) {
            case (.idle, .idle), (.loading, .loading), (.failed, .failed):
                break

            default:
                oldState = oldValue
            }
        }
    }
    private var oldState: State = .idle
    private var initialValue: T

    public init(wrappedValue: T) {
        initialValue = wrappedValue
    }
    public init(projectedValue: Self) {
        self = projectedValue
    }

    public mutating func next(_ nextState: State) {
        currentState = nextState
    }
}

 extension WithLoading: Sendable where T: Sendable {}
 extension WithLoading.State: Sendable where T: Sendable {}
