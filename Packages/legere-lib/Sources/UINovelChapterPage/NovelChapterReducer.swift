import Reactorium
import Domain

struct NovelChapterReducer: Reducer {
    struct State {
        let id: SourceID
        @WithLoading var chapter: NovelChapter?
        var isMenuActive = false
        var isPresentedSetting = false
    }
    enum Action {
        case reload(SourceID? = nil)

        case toggleMenu
        case toggleSetting

        case `internal`(Internal)

        typealias Mutate<T> = (inout T) -> Void
        enum Internal {
            case setChapter(Mutate<WithLoading<NovelChapter?>>)
        }
    }
    struct Dependency {
        var chapter: NovelChapterProvider
    }

    func reduce(into state: inout State, action: Action, dependency: Dependency) -> Effect<Action> {
        switch action {
        case .reload(let newID):
            if let newID, state.id != newID {
                state = .init(id: newID)
            }
            return .task { [id = state.id] send in
                do {
                    await send(.internal(.setChapter { $0.next(.loading) }))
                    let chapter = try await dependency.chapter.fetch(withID: id)
                    await send(.internal(.setChapter { $0.next(.loaded(chapter)) }))
                } catch {
                    await send(.internal(.setChapter { $0.next(.failed(error)) }))
                }
            }

        case .toggleMenu:
            state.isMenuActive.toggle()
            return nil

        case .toggleSetting:
            state.isPresentedSetting.toggle()
            return nil

        case .internal(.setChapter(let chapter)):
            chapter(&state.$chapter)
            return nil
        }
    }
}
