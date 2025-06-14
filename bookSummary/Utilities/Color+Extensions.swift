import SwiftUI

// Not: Uygulama renkleri merkezi bir `Theme.swift` dosyasına taşındı.
// Bu dosya, gelecekte Color'a eklenecek özel yardımcı fonksiyonlar
// veya UIColor dönüşümleri için saklanabilir.

extension UIColor {
    /// `Theme.calmingBlue` renginin UIColor karşılığı.
    static var calmingBlue: UIColor {
        UIColor(Theme.calmingBlue)
    }
    
    /// `Theme.linkedinBlue` renginin UIColor karşılığı.
    static var linkedinBlue: UIColor {
        UIColor(Theme.linkedinBlue)
    }
}
