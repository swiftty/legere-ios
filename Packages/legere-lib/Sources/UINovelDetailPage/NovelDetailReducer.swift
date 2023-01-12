import Reactorium
import Domain

struct NovelDetailReducer: Reducer {
    struct State {
        let item: RankingItem
        @WithLoading var detail: NovelDetail?
    }
    enum Action {
        case reload

        case `internal`(Internal)

        typealias Mutate<T> = (inout T) -> Void
        enum Internal {
            case setDetail(Mutate<WithLoading<NovelDetail?>>)
        }
    }
    struct Dependency {
        var detail: NovelDetailProvider
    }

    func reduce(into state: inout State, action: Action, dependency: Dependency) -> Effect<Action> {
        switch action {
        case .reload:
            return .task { [item = state.item] send in
                do {
                    await send(.internal(.setDetail { $0.next(.loading) }))
                    let detail = try await dependency.detail.fetch(from: item)
                    await send(.internal(.setDetail { $0.next(.loaded(detail)) }))
                } catch {
                    await send(.internal(.setDetail { $0.next(.failed(error)) }))
                }
            }

        case .internal(.setDetail(let detail)):
            detail(&state.$detail)
            return nil
        }
    }
}
