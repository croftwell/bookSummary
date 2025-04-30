import SwiftUI
import UIKit

// Renk Paleti Tanımları (İleride Assets veya struct içinde toplanabilir)
let corporateBlue = Color(red: 0/255, green: 119/255, blue: 181/255) 
let darkText = Color(white: 0.2) // Koyu Gri Metin
let lightGrayBackground = Color(white: 0.96)
let secondaryText = Color.gray

// Buton basılma animasyonu için özel stil
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // Basıldığında %5 küçült, bırakıldığında normale dön
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) 
            // Animasyonu yumuşat
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed) 
    }
}

struct OnboardingView: View {
    // Onboarding durumunu güncellemek için AppStorage kullanıyoruz
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    // Sayfa verileri: Artık imageName içermiyor
    let pages: [OnboardingPageData] = [
        OnboardingPageData(titleKey: "onboarding_page1_title", descriptionKey: "onboarding_page1_description"),
        OnboardingPageData(titleKey: "onboarding_page2_title", descriptionKey: "onboarding_page2_description"),
        OnboardingPageData(titleKey: "onboarding_page3_title", descriptionKey: "onboarding_page3_description")
    ]
    
    // Mevcut sayfa indeksini takip etmek için State kullanıyoruz
    @State private var currentPageIndex = 0

    // Hangi .strings dosyasını kullanacağımızı belirtelim
    private let stringsTableName = "Onboarding"

    // Haptic Feedback Jeneratörünü .rigid stili ile oluştur
    let hapticFeedback = UIImpactFeedbackGenerator(style: .rigid) // <- Stil .rigid olarak değiştirildi

    var body: some View {
        GeometryReader { geometry in
            let topSafeAreaInset = geometry.safeAreaInsets.top
            
            VStack {
                // Üst boşluk
                Spacer()
                    .frame(height: 50) 

                // Orta Kısım: Kaydırılabilir Sayfalar
                TabView(selection: $currentPageIndex) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(
                            page: pages[index], 
                            stringsTableName: stringsTableName, 
                            topInset: topSafeAreaInset
                        )
                        .tag(index) 
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: geometry.size.height * 0.75) 
                .onAppear {
                    UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(corporateBlue)
                    UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray
                 }

                // Alt Kısım: Devam Et Butonu (Artık her zaman görünür)
                Button(action: { 
                    if currentPageIndex < pages.count - 1 {
                        withAnimation {
                            currentPageIndex += 1
                        }
                        // Sayfa değiştikten sonra titreşim gönder
                        hapticFeedback.impactOccurred()
                    } else {
                        // Son sayfadaysa, onboarding'i tamamla
                        completeOnboarding()
                    }
                }, label: {
                    Text("onboarding_continue_button", tableName: stringsTableName)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(corporateBlue)
                        .cornerRadius(10)
                })
                .buttonStyle(ScaleButtonStyle())
                .controlSize(.large) 
                .padding(.horizontal, 30) 
                .padding(.bottom, max(geometry.safeAreaInsets.bottom, 20)) 
                
            }
            .ignoresSafeArea(edges: .top)
        }
        .background(Color.lightGrayBackground) 
        .edgesIgnoringSafeArea(.all) 
    }
    
    func completeOnboarding() {
        print("Onboarding tamamlandı!")
        hasCompletedOnboarding = true 
    }
}

// Tek bir onboarding sayfasının verisi: Artık imageName İÇERMİYOR
struct OnboardingPageData: Identifiable {
    let id = UUID()
    // let imageName: String // SF Symbols veya Assets'teki resim adı <- KALDIRILDI
    let titleKey: String // Başlık için yerelleştirme anahtarı
    let descriptionKey: String // Açıklama için yerelleştirme anahtarı
}

// Tek bir onboarding sayfasını gösteren SwiftUI View'ı
struct OnboardingPageView: View {
    let page: OnboardingPageData
    let stringsTableName: String 
    let topInset: CGFloat
    
    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Ana VStack artık spacing'e ihtiyaç duymayabilir veya farklı ayarlanabilir
        VStack(spacing: 0) { 
            // Assets'ten "onboarding1" resmini kullan
            Image("onboarding1") 
                .resizable()
                // Genişlik tam ekran, yükseklik yarım ekran
                .frame(width: screenWidth, height: screenHeight * 0.5) 
                .scaledToFill() // Çerçeveyi doldur, gerekirse kırp
                .clipped() // Çerçeve dışına taşmayı önle
                // .padding(.bottom, 20) // <- Kaldırıldı veya ayarlanabilir

            // Metinler için ayrı bir VStack ve padding
            VStack(spacing: 15) { // Metinler arası boşluk
                Text(LocalizedStringKey(page.titleKey), tableName: stringsTableName)
                    .font(.title2).bold() 
                    .foregroundColor(Color.darkText) 
                    .padding(.top, 30) // Resimden sonra boşluk
    
                Text(LocalizedStringKey(page.descriptionKey), tableName: stringsTableName)
                    .font(.body)
                    .foregroundColor(Color.secondaryText) 
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40) // Yanlardan boşluk devam ediyor
            }
            
            Spacer() // Kalan alanı doldurur, metinleri yukarı iter
        }
        // .padding(.top, 20) // <- Ana VStack'ten kaldırıldı
    }
}

// Önizleme için
#Preview {
    // Önizlemeyi farklı dillerde görmek için environment modifier kullanabilirsiniz
    Group {
        OnboardingView()
            .environment(\.locale, .init(identifier: "en"))
        OnboardingView()
            .environment(\.locale, .init(identifier: "tr"))
    }
} 