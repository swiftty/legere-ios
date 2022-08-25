import SwiftUI
import Domain
import UIDomain
import Concrete
import UINovelChapterPage
import UIRankingPortalPage

@main
struct App: SwiftUI.App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.router, appDelegate.dependencies.router)
                .environment(\.chapterProvider, appDelegate.dependencies.chapterProvider)
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
        lazy var rankingProvider = RankingProvider.live(session: session)
    }
}

struct RoutingProvider: UIDomain.RoutingProvider {
    func route(for target: any Routing) -> some View {
        switch target {
        case let page as Routings.ChapterPage:
            UINovelChapterPage(id: page.id, isPresented: page.context.isPresented)

        default:
            Text("undefined target: \(String(describing: target))")
        }
    }
}

struct ContentView: View {
    var body: some View {
        UIRankingPortalPage()
    }
}
