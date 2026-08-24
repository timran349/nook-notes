import SwiftUI
import AppKit

public extension Font {
    static func geist(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let fontName: String
        switch weight {
        case .bold, .heavy, .black:
            fontName = "Geist-Bold"
        case .semibold, .medium:
            fontName = "Geist-SemiBold"
        default:
            fontName = "Geist-Regular"
        }

        return Font.custom(fontName, size: size).fallback(Font.system(size: size, weight: weight, design: .default))
    }
}
