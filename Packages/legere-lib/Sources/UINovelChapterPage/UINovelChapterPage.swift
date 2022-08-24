import SwiftUI
import Domain
import UIDomain
import AttributedRubyAnnotation

public struct UINovelChapterPage: View {
    @Environment(\.chapterProvider) var chapterProvider

    let id: SourceID

    @State @WithLoading private var chapter: NovelChapter?
    @State private var isMenuActive = false
    @State private var isSettingPresented = false

    @State private var fontSize = NovelChapterView.FontSize.body

    public init(id: SourceID) {
        self.id = id
    }

    public var body: some View {
        content
            .scaleEffect(isMenuActive ? 0.84 : 1)
            .onTapGesture {
                toggleMenu()
            }
            .overlay(alignment: .top) {
                if isMenuActive {
                    topMenu
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .overlay(alignment: .bottom) {
                if isMenuActive {
                    bottomMenu
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .sheet(isPresented: $isSettingPresented) {
                settings
                    .presentationDetents([.medium, .large])
            }
            .task {
                if chapter == nil {
                    await reload()
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        ZStack {
            let isLoading = _chapter.wrappedValue.isLoading

            if let chapter {
                NovelChapterView(chapter: chapter, fontSize: fontSize)
                    .blur(radius: isLoading ? 4 : 0)
                    .animation(.easeInOut(duration: 0.1), value: isLoading)
            }
            if chapter == nil || isLoading {
                ZStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            }
        }
    }

    @ViewBuilder
    private var topMenu: some View {
        ZStack {
            HStack {
                Button {

                } label: {
                    Image(systemName: "chevron.backward")
                }

                Spacer()

                Button {
                    isSettingPresented.toggle()
                    toggleMenu()
                } label: {
                    Image(systemName: "textformat.size")
                }
            }
            .font(.body.bold())
            .foregroundStyle(.secondary)
            .padding([.leading, .trailing])
        }
        .frame(height: 44)
    }

    @ViewBuilder
    private var bottomMenu: some View {
        ZStack {
        }
        .frame(height: 44)
    }

    @ViewBuilder
    private var settings: some View {
        Form {
            Stepper(
                label: {
                    Label("font size", systemImage: "textformat.size")
                },
                onIncrement: fontSize.incr().map { next in
                    return {
                        fontSize = next
                    }
                },
                onDecrement: fontSize.decr().map { next in
                    return {
                        fontSize = next
                    }
                }
            )
        }
    }

    private func reload() async {
        await _chapter.try {
            try await chapterProvider.fetch(withID: id)
        }
    }

    private func toggleMenu() {
        withAnimation(.spring(response: 0.4)) {
            isMenuActive.toggle()
        }
    }
}

// MARK: -
struct NovelChapterView: View {
    struct FontSize: Equatable {
        var name: String
        var size: CGFloat

        static let caption = Self.init(name: "caption", size: 12)
        static let body = Self.init(name: "body", size: 20)
        static let title = Self.init(name: "title", size: 28)
        static let largeTitle = Self.init(name: "large title", size: 36)

        private static let allCases: [Self] = [
            .caption, .body, .title, .largeTitle
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
        text.font = UIFont(name: "HiraMinPro-W6", size: fontSize.size * 2)
        text.paragraphStyle = NSMutableParagraphStyle()
            .proxy
            .paragraphSpacing(fontSize.size * 3)
            .resolve()

        let endIndex = text.endIndex
        text += chapter.body
        text[endIndex...].font = UIFont(name: "HiraMinPro-W3", size: fontSize.size)

        return text
    }
}

// MARK: -

struct UINovelChapterPage_Previews: PreviewProvider {
    static var previews: some View {
        let text = try! AttributedString(markdown: """
        あのイーハトーヴォのすきとほった^[風](ruby: 'かぜ')、夏でも底に冷たさをもつ^[青](ruby: 'あお')いそら、うつくしい森で飾られたモーリオ市、^[郊外](ruby: 'こうがい')のぎらぎらひかる草の波
        """, including: \.ruby)

        return ForEach(["iPhone 8", nil], id: \.self) { device in
            NavigationView {
                UINovelChapterPage(id: .narou(""))
                    .environment(\.chapterProvider, .init(
                        fetch: { id in
                            try? await ContinuousClock().sleep(until: .now.advanced(by: .seconds(4)))
                            return NovelChapter(id: id, title: "ポラーノの広場", body: text)
                        }
                    ))
            }
            .previewDevice(device.map(PreviewDevice.init(rawValue:)))
            .previewDisplayName(device ?? "default")
        }
    }
}
