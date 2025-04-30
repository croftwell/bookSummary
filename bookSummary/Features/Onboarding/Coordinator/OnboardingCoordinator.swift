import SwiftUI
import Combine

// Uygulama genelindeki Coordinator protokolü (Eğer yoksa oluşturulmalı veya uygun olan kullanılmalı)
protocol Coordinator {
    func start() -> AnyView // Coordinator'ı başlatır ve gösterilecek ilk View'ı döndürür
}

// Onboarding akışını yöneten Coordinator
class OnboardingCoordinator: Coordinator, ObservableObject {
    // Coordinator'ın durumunu veya alt akışları yönetmek için Combine kullanılabilir
    private var cancellables = Set<AnyCancellable>()

    // Akışın tamamlandığını bildirmek için bir delegate veya closure kullanılabilir
    var didFinishOnboarding: (() -> Void)?

    // Onboarding sayfa verileri (Bunlar dışarıdan da gelebilir)
    private let onboardingPagesData: [OnboardingPageData] = [
        // Test için tüm görseller onboarding1 olarak ayarlandı
        OnboardingPageData(titleKey: "onboarding_page1_title", descriptionKey: "onboarding_page1_description", imageName: "onboarding1"),
        OnboardingPageData(titleKey: "onboarding_page2_title", descriptionKey: "onboarding_page2_description", imageName: "onboarding1"), // Görsel değiştirildi
        OnboardingPageData(titleKey: "onboarding_page3_title", descriptionKey: "onboarding_page3_description", imageName: "onboarding1") // Görsel değiştirildi
    ]

    func start() -> AnyView {
        // Container için ViewModel oluştur, sayfaları ve tamamlanma eylemini ilet
        let containerViewModel = OnboardingContainerViewModel(
            pages: onboardingPagesData,
            onComplete: { [weak self] in // Retain cycle önlemek için [weak self]
                self?.finishOnboarding()
            }
        )
        
        // Container View'ı oluştur ve ViewModel'i inject et
        let view = OnboardingContainerView(viewModel: containerViewModel)
        
        return AnyView(view)
    }

    // Onboarding akışını bitirir
    private func finishOnboarding() {
        // Üst katmanı (AppCoordinator?) bilgilendir
        didFinishOnboarding?()
    }
} 