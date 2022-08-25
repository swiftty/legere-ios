import SwiftUI
import Domain
import UIDomain
import AttributedRubyAnnotation

public struct UINovelChapterPage: View {
    @Environment(\.chapterProvider) var chapterProvider

    let id: SourceID
    @Binding var isPresented: Bool

    @State @WithLoading private var chapter: NovelChapter?
    @State private var isMenuActive = false
    @State private var isSettingPresented = false

    @State private var fontSize = NovelChapterView.FontSize.footernote

    @GestureState private var dragState = DragState.inactive

    enum DragState {
        case inactive
        case dragging(translation: CGSize)

        var translation: CGSize {
            switch self {
            case .dragging(let translation): return translation
            case .inactive: return .zero
            }
        }

        var isActive: Bool {
            switch self {
            case .inactive: return false
            case .dragging: return true
            }
        }

        var isDragging: Bool {
            switch self {
            case .dragging: return true
            case .inactive: return false
            }
        }
    }

    private var toggleMenuGesture: some Gesture {
        TapGesture()
            .onEnded {
                toggleMenu()
            }
    }

    private var dragGesture: some Gesture {
        LongPressGesture(minimumDuration: 1)
            .sequenced(before: DragGesture())
            .updating($dragState) { value, state, _ in
                switch value {
                case .first(true):
                    break

                case .second(true, let drag):
                    state = .dragging(translation: drag?.translation ?? .zero)

                default:
                    state = .inactive
                }
            }
            .onEnded { value in
                guard case .second(true, let drag?) = value else { return }
                if drag.translation.height > 150 && drag.predictedEndTranslation.height > 300 {
                    closePage()
                }
            }
    }

    public init(id: SourceID, isPresented: Binding<Bool>) {
        self.id = id
        self._isPresented = isPresented
    }

    public var body: some View {
        let isDragging = dragState.isDragging
        let offset = dragState.translation
        let isActive = dragState.isActive

        ZStack {
            content
                .scaleEffect(isMenuActive ? 0.84 : 1)
                .gesture(toggleMenuGesture)

            VStack {
                if isMenuActive {
                    topMenu
                        .transition(.move(edge: .top).combined(with: .opacity))

                    Spacer()

                    bottomMenu
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .scaleEffect(isDragging ? 0.9 : 1)
        .offset(x: offset.width / 10, y: offset.height)
        .rotation3DEffect(.degrees(offset.width / 10), axis: (0, 1, 0.1))
        .background {
            Rectangle()
                .fill(.primary.opacity(isActive ? 0 : 1))
                .colorInvert()
                .background {
                    Color.clear
                        .background(.ultraThinMaterial)
                }
                .cornerRadius(isDragging ? 20 : 0)
                .scaleEffect(isDragging ? 0.9 : 1)
                .offset(x: offset.width / 10, y: offset.height)
                .rotation3DEffect(.degrees(offset.width / 10), axis: (0, 1, 0.1))
                .ignoresSafeArea()
        }
        .mask(
            Rectangle()
                .cornerRadius(isDragging ? 20 : 0)
                .scaleEffect(isDragging ? 0.9 : 1)
                .offset(x: offset.width / 10, y: offset.height)
                .rotation3DEffect(.degrees(offset.width / 10), axis: (0, 1, 0.1))
                .ignoresSafeArea()
        )
        .gesture(dragGesture)
        .animation(.spring(), value: isDragging)
        .animation(.spring(), value: isActive)
        .sheet(isPresented: $isSettingPresented) {
            settings
                .presentationDetents([.medium, .large])
        }
        .task {
            if chapter == nil {
                await reload()
            }
        }
        .transition(
            .asymmetric(
                insertion: .move(edge: .bottom)
                    .combined(with: .opacity)
                    .combined(with: .scale(scale: 0.5)),
                removal: .move(edge: .bottom)
                    .combined(with: .opacity)
                    .combined(with: .scale(scale: 0.5, anchor: .init(x: 0.5, y: 2))))
        )
    }

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
                    isSettingPresented.toggle()
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

    private func closePage() {
        withAnimation(.spring()) {
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
        text.foregroundColor = UIColor.label

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
            """, including: \.ruby)

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
