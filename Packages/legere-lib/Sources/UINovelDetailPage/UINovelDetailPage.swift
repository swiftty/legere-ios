import SwiftUI
import Reactorium
import Domain
import UIDomain

public struct UINovelDetailPage: View {
    let item: RankingItem

    public init(item: RankingItem) {
        self.item = item
    }

    public var body: some View {
        Content()
            .store(initialState: .init(item: item), reducer: NovelDetailReducer(), dependency: {
                .init(detail: $0.detailProvider)
            })
    }

    private struct Content: View {
        @EnvironmentObject var store: StoreOf<NovelDetailReducer>

        var body: some View {
            ZStack {
                let isLoading = store.state.$detail.isLoading

                if let detail = store.state.detail {
                    DetailView(detail: detail)
                        .blur(radius: isLoading ? 4 : 0)
                        .animation(.easeInOut(duration: 0.1), value: isLoading)
                }
                if store.state.detail == nil || isLoading {
                    ZStack {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                }
                if let error = store.state.$detail.error {
                    Text("\(dump: error)")
                }
            }
            .task {
                await store.send(.reload).finish()
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
