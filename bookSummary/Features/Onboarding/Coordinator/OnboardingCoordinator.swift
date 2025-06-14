import SwiftUI
import Combine

/// Uygulama genelindeki Coordinator protokolü.
protocol Coordinator {
    /// Coordinator'ı başlatır ve gösterilecek ilk View'ı döndürür.
    func start() -> AnyView
}

/// Onboarding akışını yöneten Coordinator.
class OnboardingCoordinator: Coordinator, ObservableObject {
    
    /// Onboarding akışı tamamlandığında üst katmanı (App) bilgilendirmek için kullanılır.
    var didFinishOnboarding: (() -> Void)?

    /// Onboarding sayfa verileri. Bu veriler bir API'den veya yerel bir JSON dosyasından da gelebilir.
    private let onboardingPagesData: [OnboardingPageData] = [
        OnboardingPageData(titleKey: "onboarding_page1_title", descriptionKey: "onboarding_page1_description", imageName: "onboarding1"),
        OnboardingPageData(titleKey: "onboarding_page2_title", descriptionKey: "onboarding_page2_description", imageName: "onboarding1"),
        OnboardingPageData(titleKey: "onboarding_page3_title", descriptionKey: "onboarding_page3_description", imageName: "onboarding1")
    ]

    func start() -> AnyView {
        // Container için ViewModel oluşturulur, sayfalar ve tamamlanma eylemi iletilir.
        let containerViewModel = OnboardingContainerViewModel(
            pages: onboardingPagesData,
            onComplete: { [weak self] in
                self?.finishOnboarding()
            }
        )
        
        // Container View'ı oluşturulur ve ViewModel enjekte edilir.
        let view = OnboardingContainerView(viewModel: containerViewModel)
        
        return AnyView(view)
    }

    /// Onboarding akışını bitirir ve `didFinishOnboarding` closure'ını çağırır.
    private func finishOnboarding() {
        didFinishOnboarding?()
    }
}
