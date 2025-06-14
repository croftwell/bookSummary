import SwiftUI

struct OnboardingContainerView: View {
    
    @StateObject var viewModel: OnboardingContainerViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            pageViewer
            
            controlsOverlay
                .padding(.bottom, 60) // Kontrolleri alttan yukarı konumlandır
        }
        .background(Theme.lightGrayBackground)
        .ignoresSafeArea()
    }
    
    /// Sayfaları gösteren TabView.
    private var pageViewer: some View {
        TabView(selection: $viewModel.currentPageIndex.animation()) {
            ForEach(viewModel.pages) { pageData in
                OnboardingPageView(
                    viewModel: OnboardingViewModel(pageData: pageData)
                )
                .tag(viewModel.pages.firstIndex(of: pageData)!)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onChange(of: viewModel.currentPageIndex) { _ in
            viewModel.triggerHapticFeedback()
        }
    }
    
    /// Sayfa göstergesi ve butonu içeren katman.
    private var controlsOverlay: some View {
        VStack(spacing: 40) {
            pageIndicator
            continueButton
        }
        .padding(.horizontal)
    }
    
    /// Mevcut sayfayı gösteren özel nokta göstergesi.
    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<viewModel.pages.count, id: \.self) { index in
                Circle()
                    .fill(index == viewModel.currentPageIndex ? Theme.linkedinBlue : Color.gray.opacity(0.5))
                    .frame(width: 8, height: 8)
            }
        }
    }
    
    /// "Devam Et" veya "Başla" butonu.
    private var continueButton: some View {
        Button(action: viewModel.continueButtonTapped) {
            Text(LocalizedStringKey(viewModel.buttonTextKey), tableName: "Onboarding")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}

#Preview {
    let samplePages = [
        OnboardingPageData(titleKey: "onboarding_page1_title", descriptionKey: "onboarding_page1_description", imageName: "onboarding1"),
        OnboardingPageData(titleKey: "onboarding_page2_title", descriptionKey: "onboarding_page2_description", imageName: "onboarding1"),
        OnboardingPageData(titleKey: "onboarding_page3_title", descriptionKey: "onboarding_page3_description", imageName: "onboarding1")
    ]
    
    let containerViewModel = OnboardingContainerViewModel(pages: samplePages) {
        print("Onboarding tamamlandı!")
    }
    
    return OnboardingContainerView(viewModel: containerViewModel)
}
