import UIKit
import SwiftUI

public extension Lucide {
    public static let defaultBaselineOffset: CGFloat = -2
    
    public static func attributes(
        for originalFont: UIFont,
        baselineOffset: CGFloat = defaultBaselineOffset
    ) -> [NSAttributedString.Key: Any] {
        let targetSize: CGFloat = (originalFont.pointSize + 1)
        
        return [
            .font: UIFont(
                descriptor: (
                    Lucide.font(ofSize: targetSize).fontDescriptor.withSymbolicTraits(.traitItalic) ??
                    Lucide.font(ofSize: targetSize).fontDescriptor
                ),
                size: 0
            ),
            .baselineOffset: baselineOffset
        ]
    }
    
    public static func attributedString(
        icon: Lucide.Icon,
        size: CGFloat,
        baselineOffset: CGFloat = defaultBaselineOffset
    ) -> NSAttributedString {
        return NSAttributedString(
            string: icon.rawValue,
            attributes: [
                .font: Lucide.font(ofSize: size),
                .baselineOffset: baselineOffset
            ]
        )
    }
    
    public static func attributedString(
        icon: Lucide.Icon,
        for originalFont: UIFont,
        baselineOffset: CGFloat = defaultBaselineOffset
    ) -> NSAttributedString {
        let targetSize: CGFloat = (originalFont.pointSize + 1)
        
        return NSAttributedString(
            string: icon.rawValue,
            attributes: attributes(for: originalFont, baselineOffset: baselineOffset)
        )
    }

    public static func image(icon: Lucide.Icon, size: CGFloat, color: UIColor = .black) -> UIImage? {
        let attributedString = self.attributedString(icon: icon, size: size)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0)
        attributedString.draw(in: CGRect(x: 0, y: 0, width: size, height: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

// MARK: - UIKit

public extension Lucide.Icon {
    public func attributedString(
        for originalFont: UIFont,
        baselineOffset: CGFloat = Lucide.defaultBaselineOffset
    ) -> NSAttributedString {
        return Lucide.attributedString(icon: self, for: originalFont, baselineOffset: baselineOffset)
    }
    
    public func attributedString(
        size: CGFloat,
        baselineOffset: CGFloat = Lucide.defaultBaselineOffset
    ) -> NSAttributedString {
        return Lucide.attributedString(icon: self, size: size, baselineOffset: baselineOffset)
    }
}

extension Lucide.Icon: CustomStringConvertible {
    public var description: String { "<icon>\(rawValue)</icon>" }
}

// MARK: - SwiftUI

@available(iOS 13.0, *)
public extension Lucide.Icon {
    public func text(
        size: CGFloat,
        baselineOffset: CGFloat = Lucide.defaultBaselineOffset
    ) -> Text {
        return Text(rawValue)
            .font(Lucide.font(ofSize: size))
            .baselineOffset(baselineOffset)
    }
}
