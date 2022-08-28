import SwiftUI

struct CardComponent<Content: View>: View {
    let backgroundColor: Color
    let content: Content
    private var onDismiss: (() -> Void)?

    @GestureState private var dragState: CGSize?

    init(backgroundColor: Color, @ViewBuilder content: () -> Content) {
        self.backgroundColor = backgroundColor
        self.content = content()
    }

    var body: some View {
        let isDragging = dragState != nil
        let offset = dragState ?? .zero

        content
            .dragEffect(active: isDragging, offset: offset)
            .background {
                Rectangle()
                    .fill(backgroundColor.opacity(isDragging ? 0.4 : 1))
                    .background {
                        Color.clear
                            .background(.ultraThinMaterial)
                    }
                    .cornerRadius(isDragging ? 20 : 0)
                    .overlay {
                        if isDragging {
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(.thinMaterial, lineWidth: 2)
                        }
                    }
                    .dragEffect(active: isDragging, offset: offset)
                    .ignoresSafeArea()
            }
            .mask(
                Rectangle()
                    .cornerRadius(isDragging ? 20 : 0)
                    .dragEffect(active: isDragging, offset: offset)
                    .ignoresSafeArea()
            )
            .gesture(dragGesture)
            .animation(.spring(), value: isDragging)
    }

    func onDismiss(action: @escaping () -> Void) -> Self {
        var copy = self
        copy.onDismiss = action
        return copy
    }

    private var dragGesture: some Gesture {
        LongPressGesture(minimumDuration: 1)
            .sequenced(before: DragGesture())
            .updating($dragState) { value, state, _ in
                switch value {
                case .first(true):
                    break

                case .second(true, let drag):
                    state = drag?.translation ?? .zero

                default:
                    state = nil
                }
            }
            .onEnded { value in
                guard case .second(true, let drag?) = value else { return }
                if drag.translation.height > 150 && drag.predictedEndTranslation.height > 300 {
                    onDismiss?()
                }
            }
    }
}

private extension View {
    func dragEffect(active: Bool, offset: CGSize) -> some View {
        return self
            .scaleEffect(active ? 0.9 : 1)
            .offset(x: offset.width / 10, y: offset.height)
            .rotation3DEffect(.degrees(offset.width / 20), axis: (0, 1, 0.1))
    }
}
