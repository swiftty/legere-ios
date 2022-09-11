import SwiftUI
import Domain
import UIDomain
import Concrete
import UINovelChapterPage
import UINovelDetailPage
import UIRankingPortalPage

@main
struct App: SwiftUI.App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.router, appDelegate.dependencies.router)
                .environment(\.chapterProvider, appDelegate.dependencies.chapterProvider)
                .environment(\.detailProvider, appDelegate.dependencies.detailProvider)
                .environment(\.rankingProvider, appDelegate.dependencies.rankingProvider)
        }
    }
}

final class AppDelegate: UIResponder, UIApplicationDelegate, ObservableObject {
    private(set) lazy var dependencies = Dependencies()

    final class Dependencies {
        lazy var session = URLSession.shared
        lazy var router = Router(provider: RoutingProvider())
        lazy var chapterProvider = NovelChapterProvider.live(session: session)
        lazy var detailProvider = NovelDetailProvider.live(session: session)
        lazy var rankingProvider = RankingProvider.live(session: session)
    }
}

struct RoutingProvider: UIDomain.RoutingProvider {
    func route(for target: any Routing) -> some View {
        switch target {
        case let page as Routings.ChapterPage:
            UINovelChapterPage(id: page.id, isPresented: page.context.isPresented)

        case let page as Routings.DetailPage:
            UINovelDetailPage(item: page.item)

        default:
            Text("undefined target: \(String(describing: target))")
        }
    }
}

struct ContentView: View {
    @Environment(\.router) var router

    var body: some View {
        NavigationStack {
            UIRankingPortalPage()
                .navigationTitle("一覧")
                .navigationDestination(for: RankingItem.self) { item in
                    router.route(for: .detailPage(from: item))
                }
        }
    }
}
