import SwiftUI
import Combine

class OnboardingContainerViewModel: ObservableObject {
    
    @Published var pages: [OnboardingPageData] = []
    @Published var currentPageIndex: Int = 0
    
    private var onComplete: (() -> Void)?
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    
    var buttonTextKey: String {
        isLastPage ? "onboarding_start_button" : "onboarding_continue_button"
    }
    
    private var isLastPage: Bool {
        currentPageIndex == pages.count - 1
    }
    
    init(pages: [OnboardingPageData], onComplete: (() -> Void)?) {
        self.pages = pages
        self.onComplete = onComplete
        self.hapticFeedback.prepare()
    }
    
    func continueButtonTapped() {
        triggerHapticFeedback()
        
        if isLastPage {
            completeOnboarding()
        } else {
            goToNextPage()
        }
    }
    
    func triggerHapticFeedback() {
        hapticFeedback.impactOccurred()
    }
    
    private func goToNextPage() {
        // --- DEĞİŞİKLİK BURADA ---
        // Durum değişikliğini `withAnimation` bloğu içine alarak
        // SwiftUI'ın bu geçişi animasyonlu yapmasını sağlıyoruz.
        withAnimation {
            currentPageIndex += 1
        }
    }
    
    private func completeOnboarding() {
        onComplete?()
    }
}
