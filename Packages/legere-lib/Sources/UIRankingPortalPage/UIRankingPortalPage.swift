import SwiftUI
import Domain
import UIDomain

public struct UIRankingPortalPage: View {
    @Environment(\.rankingProvider) var rankingProvider

    @State @WithLoading private var narouItems: [RankingItem] = []

    public init() {}

    public var body: some View {
        content
            .task {
                await _narouItems.try {
                    try await rankingProvider.fetchNarouDailyRankings()
                }
            }
    }

    private var content: some View {
        ZStack {
            RankingPortalView(narouItems: _narouItems.wrappedValue)
        }
    }
}

struct RankingPortalView: View {
    @WithLoading var narouItems: [RankingItem]

    init(narouItems: WithLoading<[RankingItem]>) {
        _narouItems = narouItems
    }

    var body: some View {
        ScrollView {
            VStack {
                narouSection

                Divider()

                Spacer()
            }
            .padding(.vertical)
        }
    }

    private var narouSection: some View {
        let showsPlaceholder = _narouItems.isLoading && narouItems.isEmpty
        let items: [RankingItem] = showsPlaceholder ? [
            .placeholder,
            .placeholder,
            .placeholder
        ] : Array(narouItems.prefix(30))

        return Section {
            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    ForEach(items) { item in
                        NavigationLink(value: item) {
                            VStack(alignment: .leading) {
                                Text(item.title)
                                    .font(.body)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.primary)
                                    .padding(.vertical, 4)
                                Divider()

                                Text(item.story ?? "")
                                    .font(.caption)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.secondary)

                                Spacer()
                            }
                            .padding(8)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background {
                                Color.clear
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(8)
                            }
                            .frame(idealWidth: 200, idealHeight: 140)
                        }
                    }
                    .redacted(reason: showsPlaceholder ? .placeholder : [])
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        } header: {
            Text("??????????????????")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
        }
    }
}

extension RankingItem {
    static var placeholder: Self {
        .init(
            id: .narou(UUID().uuidString), title: "           ",
            story: "                                       ",
            auther: .init(id: .narou(UUID().uuidString), name: "            ")
        )
    }
}

// MARK: -

struct UIRaningPortalPage_Previews: PreviewProvider {
    static var previews: some View {

        return NavigationView {
            UIRankingPortalPage()
                .navigationTitle("??????")
        }
        .environment(\.rankingProvider, .init(
            fetchNarouDailyRankings: {
                try await ContinuousClock().sleep(until: .now.advanced(by: .seconds(4)))
                return [
                    .init(
                        id: .narou("1"),
                        title: "???????????? 1",
                        story: "????????????????????????????????????????????????????????????",
                        auther: .init(id: .narou("1"), name: "??????")
                    ),
                    .init(
                        id: .narou("2"),
                        title: "???????????? 2",
                        story: "????????????????????????????????????????????????????????????",
                        auther: .init(id: .narou("2"), name: "??????")
                    )
                ]
            }
        ))
        .previewDevices()
    }
}
