import SwiftUI

extension View {
    public func previewDevices() -> some View {
        ForEach([nil, "iPhone 8", "iPad Air (5th generation)"], id: \.self) { device in
            self
                .previewDevice(device.map(PreviewDevice.init(rawValue:)))
                .previewDisplayName(device ?? "default")
        }
    }
}
