import Foundation

// Onboarding sayfaları için veri yapısı
struct OnboardingPageData: Identifiable { // Identifiable, ForEach gibi yapılarla kullanmak için yararlıdır
    let id = UUID() // Her sayfa için benzersiz bir kimlik
    let titleKey: String
    let descriptionKey: String
    let imageName: String
}