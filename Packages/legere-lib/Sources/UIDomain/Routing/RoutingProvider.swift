import SwiftUI

public protocol Routing: Hashable {}

public protocol RoutingProvider {
    associatedtype ResultView: View

    @ViewBuilder
    func route(for target: any Routing) -> ResultView
}

public struct Router {
    let router: (any Routing) -> AnyView

    public func route(for target: some Routing) -> some View {
        router(target)
    }
}

extension Router {
    public init(provider: some RoutingProvider) {
        let route = provider.route(for:)
        router = { target in
            AnyView(route(target))
        }
    }
}

extension EnvironmentValues {
    private struct Key: EnvironmentKey {
        static var defaultValue: Router {
            Router { _ in
                AnyView(EmptyView())
            }
        }
    }

    public var router: Router {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }
}
