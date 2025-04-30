import SwiftUI

extension Color {
    // Uygulama genelinde kullanılacak renk paleti
    static let calmingBlue = Color(red: 100/255, green: 149/255, blue: 237/255) // Cornflower Blue
    static let darkText = Color(white: 0.2) // Koyu Gri Metin
    static let lightGrayBackground = Color(white: 0.96)
    static let secondaryText = Color.gray
    
    // İleride başka uygulama renkleri buraya eklenebilir
    // static let accentGreen = Color(red: ...)
}

// UIColor karşılıkları da gerekirse eklenebilir
extension UIColor {
    static var calmingBlue: UIColor {
        UIColor(Color.calmingBlue)
    }
    // ... diğerleri ...
} 