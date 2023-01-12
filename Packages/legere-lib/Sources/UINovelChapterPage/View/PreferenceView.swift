import SwiftUI
import Domain

struct PreferenceView: View {
    @Binding var fontSize: NovelChapterView.FontSize
    @Binding var vertical: Bool
    @Binding var colorTheme: ColorTheme

    var body: some View {
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

            LabeledContent {
                Picker(selection: $vertical) {
                    ForEach([true, false], id: \.self) { flag in
                        if flag {
                            Image(systemName: "slider.vertical.3")
                                .tag(flag)
                        } else {
                            Image(systemName: "slider.horizontal.3")
                                .tag(flag)
                        }
                    }
                } label: {
                    Text("")
                }
                .pickerStyle(.segmented)
            } label: {
                Label("direction", systemImage: "text.justify.left")
            }

            Picker(selection: $colorTheme) {
                ForEach(ColorTheme.allThemes, id: \.self) { theme in
                    Text(theme.name)
                }
            } label: {
                Label("theme", systemImage: "paintpalette")
            }
        }
    }
}
