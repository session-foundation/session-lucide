import UIKit
import SwiftUI

public enum Lucide {
    public static func font(ofSize size: CGFloat) -> UIFont {
        registerFontIfNeeded()
        
        return UIFont(name: "lucide", size: size)!
    }
    
    @available(iOS 13.0, *)
    public static func font(ofSize size: CGFloat) -> Font {
        registerFontIfNeeded()
        
        return Font.custom("lucide", size: size)
    }
    
    // MARK: - Private Helpers

    private static var isFontRegistered: Bool = false

    /// Registers the `lucide.ttf` font from the package resources if not already registered.
    private static func registerFontIfNeeded() {
        guard !isFontRegistered else { return }

        // Locate the font file in the package's module resources
        guard
            let fontUrl: URL = Bundle.module.url(forResource: "lucide", withExtension: "ttf"),
            let fontDataProvider: CGDataProvider = CGDataProvider(url: fontUrl as CFURL),
            let font: CGFont = CGFont(fontDataProvider)
        else {
            print("Failed to load lucide.ttf font resource.")
            return
        }

        // Register the font with CoreGraphics
        var error: Unmanaged<CFError>?
        
        guard CTFontManagerRegisterGraphicsFont(font, &error) else {
            let errorDescription = CFErrorCopyDescription(error?.takeRetainedValue() ?? CFErrorCreate(nil, kCFErrorDomainOSStatus, -1, nil))
            print("Failed to register lucide.ttf font: \(errorDescription ?? "unknown error" as CFString)")
            return
        }
        
        isFontRegistered = true
    }
}
