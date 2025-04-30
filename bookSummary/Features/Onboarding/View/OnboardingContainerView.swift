import SwiftUI

struct OnboardingContainerView: View {
    
    // Container'ın durumunu yöneten ViewModel
    @StateObject var viewModel: OnboardingContainerViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // TabView arka planda kalacak
                TabView(selection: $viewModel.currentPageIndex) {
                    ForEach(viewModel.pages.indices, id: \.self) { index in
                        // Her sayfa için ayrı bir OnboardingPageView oluştur
                        // Not: Her sayfa için ayrı ViewModel oluşturmak daha iyi olabilir,
                        // ama şimdilik veriyi doğrudan geçelim.
                        let pageData = viewModel.pages[index]
                        // ViewModel'i burada oluşturuyoruz (OnboardingViewModel artık basit olabilir)
                        let pageViewModel = OnboardingViewModel(pageData: pageData)
                        OnboardingPageView(viewModel: pageViewModel)
                            .tag(index) // TabView'ın seçimi takip etmesi için tag
                    }
                }
                // Varsayılan noktaları gizle
                .tabViewStyle(.page(indexDisplayMode: .never)) 
                .onChange(of: viewModel.currentPageIndex) { newIndex in
                    viewModel.triggerHapticFeedback()
                }
                // TabView'ın alt padding'ini kaldırıyoruz, ZStack ile yöneteceğiz

                // Özel Sayfa Göstergesi ve Buton için VStack
                VStack(spacing: 30) { // Noktalar ve buton arası boşluk
                    // Özel Nokta Göstergesi
                    HStack(spacing: 8) {
                        ForEach(0..<viewModel.pages.count, id: \.self) { index in
                            Circle()
                                // Aktif nokta mavi dolgulu, pasif nokta gri
                                .fill(index == viewModel.currentPageIndex ? Theme.linkedinBlue : Color.gray.opacity(0.5))
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    // Devam Et / Başla Butonu
                    Button(action: { 
                        viewModel.continueButtonTapped()
                    }) {
                        // Yerelleştirilmiş anahtarı ve tablo adını kullan
                        Text(LocalizedStringKey(viewModel.buttonTextKey), tableName: "Onboarding")
                            // Dinamik tip için font stili ekle
                            .font(.headline) 
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Theme.linkedinBlue)
                            .cornerRadius(10)
                    }
                    // Sabit padding yerine varsayılan adaptive padding kullan
                    .padding(.horizontal)
                }
                // VStack'i (Noktalar + Buton) ekranın altından yukarı konumlandır
                .padding(.bottom, 80) // Alt kenardan boşluğu artırarak grubu yukarı taşı

            }
            .background(Theme.lightGrayBackground) // Genel arka plan
            .ignoresSafeArea(.container, edges: .vertical) // İçeriğin tam ekran yayılması için
        }
    }
}

// Önizleme için örnek verilerle ViewModel oluştur
#Preview {
    let samplePages = [
        OnboardingPageData(titleKey: "onboarding_page1_title", descriptionKey: "onboarding_page1_description", imageName: "onboarding1"),
        OnboardingPageData(titleKey: "onboarding_page2_title", descriptionKey: "onboarding_page2_description", imageName: "onboarding2"),
        OnboardingPageData(titleKey: "onboarding_page3_title", descriptionKey: "onboarding_page3_description", imageName: "onboarding3") // 3. sayfa eklendi
    ]
    
    let containerViewModel = OnboardingContainerViewModel(pages: samplePages, onComplete: { 
        print("Onboarding tamamlandı!")
    })
    
    return OnboardingContainerView(viewModel: containerViewModel)
        .environment(\.locale, .init(identifier: "tr"))
} 