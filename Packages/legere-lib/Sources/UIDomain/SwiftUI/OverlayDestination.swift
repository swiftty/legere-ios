import SwiftUI

extension View {
    public func overlayDestination<K, D>(for key: K.Type,
                                         @ViewBuilder destination builder: @escaping (K, Binding<Bool>) -> D) -> some View
    where K: Hashable, D: View {
        overlayPreferenceValue(OverlayPreference.self) { data in
            if let data, let value = data.value as? K {
                builder(value, data.isPresented)
            }
        }
    }

    public func overlay<K: Hashable>(value: K?, isPresented: Binding<Bool>) -> some View {
        preference(key: OverlayPreference.self,
                   value: value.map { .init(value: $0, isPresented: isPresented) })
    }

    public func overlay<K: Hashable>(value: Binding<K?>) -> some View {
        preference(key: OverlayPreference.self,
                   value: value.wrappedValue.map { .init(value: $0, isPresented: value.asBool()) })
    }
}

private struct OverlayPreference: PreferenceKey {
    struct ContentData {
        var value: AnyHashable
        var isPresented: Binding<Bool>
    }
    static var defaultValue: ContentData?

    static func reduce(value: inout ContentData?, nextValue: () -> ContentData?) {
        value = nextValue()
    }
}
