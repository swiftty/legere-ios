import UIKit
import SwiftUI
import JapaneseAttributesKit

struct TextView: UIViewRepresentable {
    let attributedString: AttributedString

    func makeUIView(context: Context) -> View {
        let view = View()
        return view
    }

    func updateUIView(_ uiView: View, context: Context) {
        let (text, vertical) = build()
        uiView.vertical = vertical
        uiView.attributedText = text
    }

    private func build() -> (NSAttributedString, Bool) {
        do {
            return try (NSAttributedString(attributedString, including: \.japanese), attributedString.verticalGlyph ?? false)
        } catch {
            return (NSAttributedString(attributedString), false)
        }
    }
}

// MARK: -
extension TextView {
    final class View: UIView {
        var text: String {
            get { contentView.text }
            set { contentView.text = newValue }
        }
        var attributedText: NSAttributedString? {
            get { contentView.attributedText }
            set { contentView.attributedText = newValue }
        }
        var vertical: Bool = false {
            didSet {
                contentView.transform = vertical ? .init(rotationAngle: .pi / 2) : .identity
            }
        }

        private let contentView = ContentView()

        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(contentView)
            contentView.frame = bounds
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            contentView.contentInset.top = 8
            contentView.contentInset.bottom = 8
            contentView.contentInsetAdjustmentBehavior = .never
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            contentView.frame = bounds
        }

        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)
            if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
                contentView.setNeedsDisplay()
            }
        }
    }
}

// MARK: -
private final class ContentView: UIScrollView {
    var text: String {
        get { textContentStorage.attributedString?.string ?? "" }
        set { setText(newValue) }
    }
    var attributedText: NSAttributedString? {
        get { textContentStorage.attributedString }
        set { setText(newValue) }
    }

    private let textLayoutManager = NSTextLayoutManager()
    private let textContentStorage = NSTextContentStorage()

    private let layers = NSMapTable<NSTextLayoutFragment, TextLayoutFragmentLayer>.weakToWeakObjects()
    private let contentLayer = TextLayer()

    private var updatingLayers: Set<CALayer> = []
    private var updatingOffsets: Set<CGFloat> = []
    private var updating = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        textLayoutManager.textViewportLayoutController.delegate = self

        textContentStorage.addTextLayoutManager(textLayoutManager)
        textLayoutManager.textContainer = NSTextContainer(size: .init(width: 200, height: 0))

        contentLayer.frame = bounds
        layer.addSublayer(contentLayer)
        alwaysBounceVertical = true
        clipsToBounds = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !updating {
            updateContainerSizeIfNeeded()
            textLayoutManager.textViewportLayoutController.layoutViewport()
        }
        contentLayer.frame = CGRect(origin: .zero, size: contentSize)
    }

    override func setNeedsDisplay() {
        super.setNeedsDisplay()

        contentLayer.sublayers?.forEach {
            $0.setNeedsDisplay()
        }
    }
}

extension ContentView {
    private func setText(_ string: String?) {
        setText(string.map(NSAttributedString.init(string:)))
    }

    private func setText(_ string: NSAttributedString?) {
        textContentStorage.performEditingTransaction {
            textContentStorage.attributedString = string
        }
        layer.setNeedsLayout()
    }

    private func updateContainerSizeIfNeeded() {
        guard let container = textLayoutManager.textContainer else { return }
        if container.size.width != bounds.width {
            container.size = CGSize(width: bounds.width, height: 0)
            layer.setNeedsLayout()
        }
    }

    private func updateContentSizeIfNeeded() {
        let currentHeight = contentSize.height
        var height = 0 as CGFloat
        textLayoutManager.enumerateTextLayoutFragments(from: textLayoutManager.documentRange.endLocation,
                                                       options: [.reverse, .ensuresLayout]) { fragment in
            height = fragment.layoutFragmentFrame.maxY
            return false
        }

        let maxHeight = updatingLayers.map(\.frame.maxY).max() ?? 0
        if abs(currentHeight - height) > 1e-10, height > maxHeight {
            contentSize = CGSize(width: bounds.width, height: height)
        } else if maxHeight > contentSize.height {
            contentSize = CGSize(width: bounds.width, height: maxHeight)
        }
    }

    private func adjustViewportOffsetIfNeeded() {
        guard !updatingOffsets.isEmpty else { return }
        let diff = updatingOffsets.reduce(0, +) / CGFloat(updatingOffsets.count)
        contentOffset.y -= diff
    }
}

extension ContentView: NSTextViewportLayoutControllerDelegate {
    func viewportBounds(for textViewportLayoutController: NSTextViewportLayoutController) -> CGRect {
        CGRect(origin: contentOffset, size: bounds.size)
            .insetBy(dx: 0, dy: -100)
    }

    func textViewportLayoutControllerWillLayout(_ textViewportLayoutController: NSTextViewportLayoutController) {
        updating = true
        updatingLayers = []
        updatingOffsets = []
    }

    func textViewportLayoutController(_ textViewportLayoutController: NSTextViewportLayoutController,
                                      configureRenderingSurfaceFor textLayoutFragment: NSTextLayoutFragment) {
        func findLayer() -> (TextLayoutFragmentLayer, Bool) {
            if let layer = layers.object(forKey: textLayoutFragment) {
                return (layer, true)
            } else {
                let layer = TextLayoutFragmentLayer(layoutFragment: textLayoutFragment, contentsScale: window?.screen.scale ?? 2)
                layers.setObject(layer, forKey: textLayoutFragment)
                return (layer, false)
            }
        }

        let (layer, found) = findLayer()
        if found {
            let oldPosition = layer.position
            let oldBounds = layer.bounds
            layer.updateGeometry()
            if oldBounds != layer.bounds {
                layer.setNeedsDisplay()
            }
            if oldPosition != layer.position {
                updatingOffsets.insert(oldPosition.y - layer.position.y)
            }
        }

        updatingLayers.insert(layer)
        contentLayer.addSublayer(layer)
    }

    func textViewportLayoutControllerDidLayout(_ textViewportLayoutController: NSTextViewportLayoutController) {
        defer { updating = false }
        for layer in contentLayer.sublayers ?? [] where !updatingLayers.contains(layer) {
            layer.removeFromSuperlayer()
        }
        updateContentSizeIfNeeded()
        adjustViewportOffsetIfNeeded()
    }
}

