import SwiftUI
import Domain
import Concrete
import UINovelChapterPage
import UIRankingPortalPage

@main
struct App: SwiftUI.App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.rankingProvider, appDelegate.dependencies.rankingProvider)
        }
    }
}

final class AppDelegate: UIResponder, UIApplicationDelegate, ObservableObject {
    private(set) lazy var dependencies = Dependencies()

    final class Dependencies {
        lazy var session = URLSession.shared
        lazy var rankingProvider = RankingProvider.live(session: session)
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            UIRankingPortalPage()
                .navigationTitle("一覧")
        }
    }
}
