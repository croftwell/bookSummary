import SwiftUI
import Combine

class OnboardingContainerViewModel: ObservableObject {
    
    /// Tüm onboarding sayfalarının verileri.
    @Published var pages: [OnboardingPageData] = []
    
    /// Şu anda görüntülenen sayfanın indeksi.
    @Published var currentPageIndex: Int = 0
    
    /// Akışın tamamlandığını bildirmek için Coordinator'a iletilecek eylem.
    private var onComplete: (() -> Void)?
    
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    
    /// Buton metni için dinamik olarak lokalizasyon anahtarını döndürür.
    var buttonTextKey: String {
        isLastPage ? "onboarding_start_button" : "onboarding_continue_button"
    }
    
    /// Mevcut sayfanın son sayfa olup olmadığını kontrol eder.
    private var isLastPage: Bool {
        currentPageIndex == pages.count - 1
    }
    
    init(pages: [OnboardingPageData], onComplete: (() -> Void)?) {
        self.pages = pages
        self.onComplete = onComplete
        self.hapticFeedback.prepare()
    }
    
    /// "Devam Et" / "Başla" butonuna basıldığında çağrılır.
    func continueButtonTapped() {
        triggerHapticFeedback()
        
        if isLastPage {
            completeOnboarding()
        } else {
            goToNextPage()
        }
    }
    
    /// Sayfa değiştiğinde haptic geri bildirimini tetikler.
    func triggerHapticFeedback() {
        hapticFeedback.impactOccurred()
    }
    
    private func goToNextPage() {
        currentPageIndex += 1
    }
    
    private func completeOnboarding() {
        onComplete?()
    }
}
