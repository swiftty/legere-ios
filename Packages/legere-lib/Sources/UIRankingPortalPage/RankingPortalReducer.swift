import Reactorium
import Domain

struct RankingPortalReducer: Reducer {
    struct State {
        @WithLoading var narouItems: [RankingItem] = []
    }
    enum Action {
        case reload

        case `internal`(Internal)

        typealias Mutate<T> = (inout T) -> Void
        enum Internal {
            case setNarouItems(Mutate<WithLoading<[RankingItem]>>)
        }
    }
    struct Dependency {
        var ranking: RankingProvider
    }

    func reduce(into state: inout State, action: Action, dependency: Dependency) -> Effect<Action> {
        switch action {
        case .reload:
            return .task { send in
                do {
                    await send(.internal(.setNarouItems { $0.next(.loading) }))
                    let narouItems = try await dependency.ranking.fetchNarouDailyRankings()
                    await send(.internal(.setNarouItems { $0.next(.loaded(narouItems)) }))
                } catch {
                    await send(.internal(.setNarouItems { $0.next(.failed(error)) }))
                }
            }

        case .internal(.setNarouItems(let mutate)):
            mutate(&state.$narouItems)
            return nil
        }
    }
}
