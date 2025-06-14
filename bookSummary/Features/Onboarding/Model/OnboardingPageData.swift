import Foundation

/// Tek bir onboarding sayfasının veri modelini temsil eder.
struct OnboardingPageData: Identifiable, Hashable {
    /// `Identifiable` protokolü için benzersiz bir kimlik.
    let id = UUID()
    /// Lokalizasyon dosyasındaki başlık anahtarı.
    let titleKey: String
    /// Lokalizasyon dosyasındaki açıklama anahtarı.
    let descriptionKey: String
    /// Assets'teki görselin adı.
    let imageName: String
}
