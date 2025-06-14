import SwiftUI

/// Uygulama genelindeki renkleri ve stilleri barındıran merkezi yapı.
struct Theme {
    
    // MARK: - Ana Renkler
    static let darkText: Color = .primary
    static let secondaryText: Color = .secondary
    static let lightGrayBackground: Color = Color(UIColor.systemGroupedBackground)
    
    /// Ana vurgu rengi.
    static let linkedinBlue = Color(red: 0.0, green: 114.0/255.0, blue: 177.0/255.0)
    
    /// Tab bar gibi UI elemanları için kullanılan sakin mavi tonu.
    static let calmingBlue = Color(red: 100/255, green: 149/255, blue: 237/255)

    // MARK: - Form Alanı Renkleri
    
    /// Form alanlarının varsayılan arkaplanı.
    static let fieldBackground: Color = Color(UIColor.systemGray6)
    
    /// Odaklanılmış form alanı için renkler.
    static let focusedBorder: Color = linkedinBlue
    static let focusedBackground: Color = linkedinBlue.opacity(0.1)
    
    /// Geçersiz giriş yapılmış form alanı için renkler.
    static let invalidBorder: Color = .red
    static let invalidBackground: Color = Color.red.opacity(0.1)
}
