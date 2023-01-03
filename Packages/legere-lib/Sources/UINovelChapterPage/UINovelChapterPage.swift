import SwiftUI
import Reactorium
import Domain
import UIDomain
import JapaneseAttributesKit

public struct UINovelChapterPage: View {
    let id: SourceID
    @Binding var isPresented: Bool

    public init(id: SourceID, isPresented: Binding<Bool>) {
        self.id = id
        self._isPresented = isPresented
    }

    public var body: some View {
        Content(id: id, isPresented: $isPresented)
            .store(initialState: .init(id: id), reducer: NovelChapterReducer(), dependency: {
                .init(chapter: $0.chapterProvider)
            })
    }

    private struct Content: View {
        let id: SourceID
        @Binding var isPresented: Bool

        @EnvironmentObject var store: StoreOf<NovelChapterReducer>

        var body: some View {
            UINovelChapterContent(isPresented: $isPresented)
                .task {
                    await store.send(.reload()).finish()
                }
                .onChange(of: id) { id in
                    store.send(.reload(id))
                }
        }
    }
}

// MARK: -
struct UINovelChapterContent: View {
    @Binding var isPresented: Bool

    @EnvironmentObject var store: StoreOf<NovelChapterReducer>

    @State private var fontSize = NovelChapterView.FontSize.footernote
    @State private var vertical: Bool = true
    @State private var colorTheme: ColorTheme = .system

    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }

    var body: some View {
        CardComponent(backgroundColor: .init(uiColor: colorTheme.backgroundColor)) {
            ZStack {
                content
                    .scaleEffect(store.state.isMenuActive ? 0.84 : 1)
                    .onTapGesture {
                        toggleMenu()
                    }

                VStack {
                    if store.state.isMenuActive {
                        topMenu
                            .transition(.move(edge: .top).combined(with: .opacity))

                        Spacer()

                        bottomMenu
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
        .onDismiss(action: closePage)
        .sheet(isPresented: store.$state.isPresentedSetting(action: .toggleSetting)) {
            PreferenceView(fontSize: $fontSize, vertical: $vertical, colorTheme: $colorTheme)
                .presentationDetents([.medium])
        }
        .transition(
            .move(edge: .bottom)
            .combined(with: .opacity)
            .combined(with: .scale(scale: 0.5, anchor: .init(x: 0.5, y: 2)))
            .animation(.spring(response: 0.4).speed(1.2))
        )
    }

    private var content: some View {
        ZStack {
            let isLoading = store.state.$chapter.isLoading

            if let chapter = store.state.chapter {
                NovelChapterView(chapter: chapter, fontSize: fontSize, vertical: vertical, colorTheme: colorTheme)
                    .blur(radius: isLoading ? 4 : 0)
                    .animation(.easeInOut(duration: 0.1), value: isLoading)
            }
            if store.state.chapter == nil || isLoading {
                ZStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            }
        }
    }

    private var topMenu: some View {
        ZStack {
            HStack {
                Button {
                    closePage()
                } label: {
                    Image(systemName: "chevron.backward")
                        .padding()
                }

                Spacer()

                Button {
                    store.send(.toggleSetting)
                    toggleMenu()
                } label: {
                    Image(systemName: "textformat.size")
                        .padding()
                }
            }
            .font(.body.bold())
            .foregroundStyle(.secondary)
            .padding([.leading, .trailing])
        }
        .frame(height: 44)
    }

    private var bottomMenu: some View {
        ZStack {
        }
        .frame(height: 44)
    }

    private func toggleMenu() {
        store.send(.toggleMenu, animation: .spring(response: 0.4))
    }

    private func closePage() {
        withAnimation(.spring().speed(1.2)) {
            isPresented = false
        }
    }
}

// MARK: -
struct NovelChapterView: View {
    struct FontSize: Equatable {
        var name: String
        var size: CGFloat

        static let caption = Self.init(name: "caption", size: 12)
        static let footernote = Self.init(name: "footernote", size: 16)
        static let body = Self.init(name: "body", size: 20)
        static let title = Self.init(name: "title", size: 28)
        static let largeTitle = Self.init(name: "large title", size: 36)

        private static let allCases: [Self] = [
            .caption, .footernote, .body, .title, .largeTitle
        ]

        func decr() -> FontSize? {
            let values = Self.allCases
            guard let index = values.firstIndex(of: self) else { return nil }
            return values.indices.contains(index - 1) ? values[index - 1] : nil
        }

        func incr() -> FontSize? {
            let values = Self.allCases
            guard let index = values.firstIndex(of: self) else { return nil }
            return values.indices.contains(index + 1) ? values[index + 1] : nil
        }
    }

    let chapter: NovelChapter
    let fontSize: FontSize
    let vertical: Bool
    let colorTheme: ColorTheme

    var body: some View {
        TextView(attributedString: attributedString)
    }

    private var attributedString: AttributedString {
        var text: AttributedString
        if let title = chapter.title {
            text = AttributedString(title + "\n")
        } else {
            text = AttributedString("")
        }
        text.font = UIFont(name: "HiraMinPro-W6", size: (fontSize.size * 1.2).rounded())
        text.paragraphStyle = NSMutableParagraphStyle()
            .proxy
            .paragraphSpacing(fontSize.size * 2)
            .resolve()

        let endIndex = text.endIndex
        text += chapter.body
        text[endIndex...].font = UIFont(name: "HiraMinPro-W3", size: fontSize.size)
        text.verticalGlyph = vertical
        text.foregroundColor = colorTheme.textColor

        return text
    }
}

// MARK: -

struct UINovelChapterPage_Previews: PreviewProvider {
    struct Preview: View {
        @State var isPresented = true

        var body: some View {
            let text = try! AttributedString(markdown: """
            あのイーハトーヴォのすきとほった^[風](ruby: 'かぜ')、夏でも底に冷たさをもつ^[青](ruby: 'あお')いそら、うつくしい森で飾られたモーリオ市、^[郊外](ruby: 'こうがい')のぎらぎらひかる草の波
            """, including: \.japanese)

            return ZStack {
                Color.blue
                    .ignoresSafeArea()
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
                                    return NovelChapter(id: id, title: "ポラーノの広場", body: text)
                                }
                            ))
                    }
                }
            }
            .previewDevices()
        }
    }

    static var previews: some View {
        Preview()
    }
}
