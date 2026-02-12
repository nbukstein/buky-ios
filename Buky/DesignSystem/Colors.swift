import SwiftUI

extension Color {
    // Primary Palette
    static let primaryBrand = Color(hex: "#667EEA")
    static let secondaryBrand = Color(hex: "#764BA2")
    
    static let tertiaryBrand = Color(hex: "#F472B6")
    static let cuarterlyBrand = Color(hex: "#A855F7")
    
    static let savedColorOne = Color(hex: "#60A5FA")
    static let savedColorTwo = Color(hex: "#6366F1")
    

    // Neutral Palette
    static let backgroundPrimary = Color(hex: "#FFFFFF")  // White
    static let textPrimary = Color(hex: "#000000")        // Black
    static let borderGray = Color(hex: "#C6C6C6")         // Light Gray
    
    // Status Colors
    static let errorRed = Color(hex: "#FF3B30")
    static let successGreen = Color(hex: "#34C759")
}

fileprivate extension Color {
    // Custom initializer to create a SwiftUI Color from a hex string (e.g., "#RRGGBB" or "RRGGBB")
    init(hex: String) {
        let hexSanitized = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted
        )
        var rgb: UInt64 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        let length = hexSanitized.count

        // Ensure the string has 6 characters for RRGGBB
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            self.init(red: 0.0, green: 0.0, blue: 0.0) // Fallback color
            return
        }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            // Optional: Support ARGB format if needed
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
        }

        self.init(red: r, green: g, blue: b)
    }
    
}
