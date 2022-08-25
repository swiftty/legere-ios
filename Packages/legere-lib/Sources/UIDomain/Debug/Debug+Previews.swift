import SwiftUI

extension View {
    public func previewDevices() -> some View {
        ForEach(["iPhone 8", nil], id: \.self) { device in
            self
                .previewDevice(device.map(PreviewDevice.init(rawValue:)))
                .previewDisplayName(device ?? "default")
        }
    }
}
