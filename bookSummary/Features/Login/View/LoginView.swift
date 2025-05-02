import SwiftUI

struct LoginView: View {
    
    @StateObject var viewModel = LoginViewModel() // StateObject olarak değiştirildi
    
    var body: some View {
        // Ana ZStack kaldırıldı, alert artık AuthenticationSheetView içinde
        NavigationView { 
            // İçerik doğrudan VStack'te
            VStack(spacing: 20) {
                Spacer()
                
                Text("Giriş Yap veya Kaydol")
                    .font(.largeTitle).bold()
                    .padding(.bottom, 30)
                
                // Giriş Butonları
                SocialLoginButton(provider: .apple) { /* TODO: viewModel.appleLoginRequested() */ }
                SocialLoginButton(provider: .google) { /* TODO: viewModel.googleLoginRequested() */ }
                
                Divider()
                    .padding(.vertical)
                
                // Mail ile Giriş / Kaydol
                Button("Mail ile Devam Et") {
                    viewModel.requestShowSignup()
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Spacer()
                Spacer()
            }
            .padding()
            .navigationBarHidden(true) // Navigation bar gizlense bile stil etkili olabilir
        }
        // Tablette stack stilini zorlamak için modifier eklendi
        .navigationViewStyle(.stack)
        // Ana Kimlik Doğrulama Sheet'i NavigationView'a ekleniyor
        .sheet(isPresented: Binding<Bool>( 
            get: { viewModel.currentSheetMode != .none },
            set: { if !$0 { viewModel.dismissSheet() } } 
        )) {
            AuthenticationSheetView(loginViewModel: viewModel)
                .environmentObject(viewModel) 
        }
        // Alert kodu buradaydı, kaldırıldı.
    }
}

// --- Yardımcı View ve Stiller (Ayrı dosyalara taşınabilir) ---

enum SocialProvider {
    case apple, google
    
    var title: String {
        switch self {
        case .apple: return "Apple ile Devam Et"
        case .google: return "Google ile Devam Et"
        }
    }
    
    // İkonlar için SF Symbols veya Asset isimleri eklenebilir
}

struct SocialLoginButton: View {
    let provider: SocialProvider
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                // İkon eklenebilir (örn. Image(systemName: "applelogo"))
                Spacer()
                Text(provider.title)
                Spacer()
            }
            .padding()
            .background(Color(UIColor.systemGray5))
            .foregroundColor(.primary)
            .cornerRadius(10)
        }
    }
}

// PrimaryButtonStyle tanımı merkezi dosyaya taşındı.

// --- Önizleme ---

#Preview {
    LoginView()
} 