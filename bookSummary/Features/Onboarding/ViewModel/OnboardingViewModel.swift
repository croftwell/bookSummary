import Foundation
import Combine // ViewModel genellikle state yönetimi için Combine kullanır

// Onboarding sayfası için verileri ve durumu yönetecek ViewModel
class OnboardingViewModel: ObservableObject {
    // @Published ile işaretlenen değişkenler, SwiftUI View'larının otomatik olarak güncellenmesini sağlar
    @Published var currentPageData: OnboardingPageData

    // Başlangıç verisiyle ViewModel'i başlat
    init(pageData: OnboardingPageData) {
        self.currentPageData = pageData
    }

    // Gelecekte buraya sayfa değiştirme, akışı tamamlama gibi mantıklar eklenebilir.
    // Örneğin:
    // func nextButtonTapped() { ... }
    // func skipButtonTapped() { ... }
}

// OnboardingPageData struct tanımı yeni Model dosyasına taşındı. 