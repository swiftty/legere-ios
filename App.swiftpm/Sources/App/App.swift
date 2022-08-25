import SwiftUI
import Domain
import Concrete
import UINovelChapterPage

@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {

    @State private var isPresented = true

    var body: some View {
        var text = try! AttributedString(markdown: """
        あのイーハトーヴォのすきとほった^[風](ruby: 'かぜ')、夏でも底に冷たさをもつ^[青](ruby: 'あお')いそら、うつくしい森で飾られたモーリオ市、^[郊外](ruby: 'こうがい')のぎらぎらひかる草の波
        """, including: \.ruby)
        text.font = UIFont(name: "HiraMinPro-W3", size: 20)
        text.foregroundColor = UIColor.label

        return NavigationView {
            ZStack {
                Color.blue.ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isPresented.toggle()
                        }
                    }

                VStack {
                    if isPresented {
                        UINovelChapterPage(id: .narou(""), isPresented: $isPresented)
                            .environment(\.chapterProvider, .init(
                                fetch: { id in
                                    try? await ContinuousClock().sleep(until: .now.advanced(by: .seconds(1)))
                                    return NovelChapter(id: id, body: text)
                                }
                            ))
                    }
                }
            }
        }
    }
}
