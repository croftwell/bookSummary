import SwiftUI

// Tek bir onboarding sayfasını gösteren SwiftUI View'ı
struct OnboardingPageView: View {
    // Doğrudan PageData yerine ViewModel'i tutar
    @StateObject var viewModel: OnboardingViewModel

    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

        VStack(spacing: 0) {
            // Verileri ViewModel üzerinden al
            Image(viewModel.currentPageData.imageName)
                .resizable()
                // Farklı cihazlarda kırpmayı önlemek için .scaledToFit() kullan
                .scaledToFit()
                .frame(width: screenWidth, height: screenHeight * 0.5)
                // .scaledToFill()
                .clipped() // scaledToFit ile clipped genellikle gereksizdir, ama kalabilir

            VStack(spacing: 15) {
                // Verileri ViewModel üzerinden al ve doğru tabloyu belirt
                Text(LocalizedStringKey(viewModel.currentPageData.titleKey), tableName: "Onboarding")
                    .font(.title2).bold()
                    .foregroundColor(Theme.darkText)
                    .padding(.top, 30)

                // Verileri ViewModel üzerinden al ve doğru tabloyu belirt
                Text(LocalizedStringKey(viewModel.currentPageData.descriptionKey), tableName: "Onboarding")
                    .font(.body)
                    .foregroundColor(Theme.secondaryText)
                    .multilineTextAlignment(.center)
                    // Sabit padding yerine varsayılan adaptive padding kullan
                    .padding(.horizontal)
            }

            Spacer()
        }
        .background(Theme.lightGrayBackground)
    }
}

// Önizleme, ViewModel'i başlatarak güncellenmeli
#Preview {
    // Örnek bir OnboardingPageData oluştur
    let samplePageData = OnboardingPageData(
        titleKey: "onboarding_page1_title",
        descriptionKey: "onboarding_page1_description",
        imageName: "onboarding1"
    )
    // ViewModel'i bu veriyle başlat
    let viewModel = OnboardingViewModel(pageData: samplePageData)

    OnboardingPageView(viewModel: viewModel)
        .environment(\.locale, .init(identifier: "tr"))
}