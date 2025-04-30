import SwiftUI
import Combine

class OnboardingContainerViewModel: ObservableObject {
    
    // Tüm onboarding sayfalarının verileri
    // Bu veriler Coordinator'dan veya bir servisten enjekte edilebilir.
    @Published var pages: [OnboardingPageData] = []
    
    // Şu anda görüntülenen sayfanın indeksi (TabView ile bağlanacak)
    @Published var currentPageIndex: Int = 0
    
    // Akışın tamamlandığını bildirmek için Coordinator'a iletilecek eylem
    var onComplete: (() -> Void)?
    
    // Haptic feedback için yardımcı
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    
    // Buton için yerelleştirme anahtarını döndürür
    var buttonTextKey: String {
        if currentPageIndex == pages.count - 1 {
            return "onboarding_start_button" // Son sayfa için anahtar
        } else {
            return "onboarding_continue_button" // Diğer sayfalar için anahtar
        }
    }
    
    // Başlatıcı (Initializer)
    // Coordinator bu ViewModel'i oluştururken sayfaları ve tamamlanma eylemini iletecek.
    init(pages: [OnboardingPageData], onComplete: (() -> Void)?) {
        self.pages = pages
        self.onComplete = onComplete
        hapticFeedback.prepare() // Haptic motorunu önceden hazırla
    }
    
    // "Devam Et" / "Başla" butonuna basıldığında çağrılır
    func continueButtonTapped() {
        triggerHapticFeedback() // Titreşim ver
        
        if currentPageIndex < pages.count - 1 {
            // Son sayfada değilsek, bir sonraki sayfaya git
            // Animasyonla geçiş yapmak için withAnimation kullan
            withAnimation {
                currentPageIndex += 1
            }
        } else {
            // Son sayfadaysak, onboarding'i tamamla
            // İsteğe bağlı olarak burada da bir animasyon (örn. fade out) düşünülebilir
            completeOnboarding()
        }
    }
    
    // Onboarding akışını tamamlar
    private func completeOnboarding() {
        onComplete?()
    }
    
    // Sayfa değiştiğinde haptic geri bildirimi tetikler
    // Bu, currentPageIndex'in değiştiği her yerde çağrılabilir.
    func triggerHapticFeedback() {
        hapticFeedback.impactOccurred()
    }
} 