import SwiftUI

struct Theme {
    static let darkText: Color = .black // Gerçek renklerle değiştirin
    static let secondaryText: Color = .gray // Gerçek renklerle değiştirin
    static let lightGrayBackground: Color = Color(UIColor.systemGray6) // Gerçek renklerle değiştirin
    
    // LinkedIn Mavisi (#0072b1)
    static let linkedinBlue: Color = Color(red: 0.0, green: 114.0/255.0, blue: 177.0/255.0)
    
    // Odaklanma durumları için renkler
    static let focusedBorder: Color = linkedinBlue // Kenarlık için ana rengi kullanalım
    static let focusedBackground: Color = linkedinBlue.opacity(0.1) // Ana rengin soluk tonu
    
    // Alanların varsayılan arka planı
    static let fieldBackground: Color = Color(UIColor.systemGray6)
    
    // Geçersiz durumlar için renkler
    static let invalidBorder: Color = .red
    static let invalidBackground: Color = Color.red.opacity(0.1)
    
    // Diğer tema sabitlerini buraya ekleyebilirsiniz
} 