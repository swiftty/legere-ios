import SwiftUI
import Domain
import UIDomain

public struct UINovelDetailPage: View {
    @Environment(\.detailProvider) var detailProvider

    let item: RankingItem

    @State @WithLoading private var detail: NovelDetail?

    public init(item: RankingItem) {
        self.item = item
    }

    public var body: some View {
        content
            .task {
                await _detail.try {
                    try await detailProvider.fetch(from: item)
                }
            }
    }

    private var content: some View {
        ZStack {
            let isLoading = _detail.wrappedValue.isLoading

            if let detail {
                DetailView(detail: detail)
                    .blur(radius: isLoading ? 4 : 0)
                    .animation(.easeInOut(duration: 0.1), value: isLoading)
            }
            if detail == nil || isLoading {
                ZStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            }
            if let error = _detail.wrappedValue.error {
                Text("\(dump: error)")
            }
        }
    }
}

struct DetailView: View {
    @Environment(\.router) var router

    var detail: NovelDetail
    @State private var selectedID: SourceID?

    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    if let story = detail.story {
                        Text(story)
                    }

                    Section {
                        ForEach(detail.index) { index in
                            Button {
                                selectedID = index.id
                            } label: {
                                Text(index.title ?? "")
                                    .multilineTextAlignment(.leading)
                            }
                        }
                    } header: {
                        Text("chapter")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(detail.title)
        .overlay(value: $selectedID)
    }
}
