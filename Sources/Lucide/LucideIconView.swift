import UIKit

public class LucideIconView: UIView {
    private let textLayer = CATextLayer()

    public var icon: Lucide.Icon? {
        didSet { updateLayerString() }
    }

    public var iconSize: CGFloat = 24 {
        didSet {
            updateLayerFont()
            invalidateIntrinsicContentSize()
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: iconSize, height: iconSize)
    }

    public override var tintColor: UIColor! {
        didSet {
            textLayer.foregroundColor = tintColor.cgColor
        }
    }

    // MARK: - Initialization

    public init(icon: Lucide.Icon, size: CGFloat = 24) {
        self.icon = icon
        self.iconSize = size

        super.init(frame: .zero)
        commonInit()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .clear
        
        textLayer.font = Lucide.font(ofSize: iconSize)
        textLayer.fontSize = iconSize
        textLayer.alignmentMode = .center
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.foregroundColor = tintColor.cgColor
        
        layer.addSublayer(textLayer)

        updateLayerString()
    }

    // MARK: - Lifecycle

    public override func layoutSubviews() {
        super.layoutSubviews()
        
        textLayer.frame = bounds
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                textLayer.foregroundColor = tintColor.cgColor
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func updateLayerString() {
        textLayer.string = icon?.rawValue
    }
    
    private func updateLayerFont() {
        textLayer.font = Lucide.font(ofSize: iconSize)
        textLayer.fontSize = iconSize
    }
}
