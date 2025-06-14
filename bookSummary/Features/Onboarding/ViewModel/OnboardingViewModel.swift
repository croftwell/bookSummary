import Foundation
import Combine

/// Tek bir `OnboardingPageView` için veri ve durumu yönetir.
class OnboardingViewModel: ObservableObject {
    
    /// View tarafından görüntülenecek olan sayfa verisi.
    @Published var pageData: OnboardingPageData

    init(pageData: OnboardingPageData) {
        self.pageData = pageData
    }
}
