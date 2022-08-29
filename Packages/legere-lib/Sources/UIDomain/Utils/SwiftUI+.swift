import SwiftUI
import OSLog

extension Binding {
    public func asBool<T>() -> Binding<Bool> where Value == T? {
        return Binding<Bool>(
            get: {
                wrappedValue != nil
            },
            set: { newValue in
                if !newValue {
                    wrappedValue = nil
                } else {
                    os_log(
                        .error,
                        "Optional binding mapped to optional has been set to `true`, which will have no effect. Current value: %@",
                        String(describing: wrappedValue)
                    )
                }
            }
        )
    }
}
