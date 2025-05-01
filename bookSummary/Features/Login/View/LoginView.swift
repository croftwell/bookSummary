import SwiftUI

struct LoginView: View {
    
    // ViewModel dışarıdan Coordinator tarafından inject edilecek
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        NavigationView { 
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
                    // TODO: Bu buton ya doğrudan Email Login'i açmalı ya da
                    // bir ara seçim sunup Login/Signup'ı viewModel'e bildirmeli.
                    // Şimdilik Signup'ı tetikleyelim:
                    viewModel.requestShowSignup()
                }
                .buttonStyle(PrimaryButtonStyle())
                
                // Şifremi Unuttum Butonu (Örnek)
                Button("Şifremi Unuttum") {
                    viewModel.requestShowForgotPassword()
                }
                .font(.footnote)
                .padding(.top, 5)
                
                Spacer()
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
            // Eski sheet modifier'ları kaldırıldı
            // .sheet(isPresented: $viewModel.isPresentingSignupSheet) { ... }
            // .sheet(isPresented: $viewModel.isPresentingEmailLoginSheet) { ... }
            // .sheet(isPresented: $viewModel.isPresentingForgotPasswordSheet) { ... }
            
            // Yeni tek sheet modifier
            .sheet(isPresented: Binding<Bool>( // currentSheetMode != .none olduğunda göster
                get: { viewModel.currentSheetMode != .none },
                set: { if !$0 { viewModel.dismissSheet() } } // Kapatıldığında modu .none yap
            )) {
                // AuthenticationSheetView'ı viewModel ile sun
                AuthenticationSheetView(loginViewModel: viewModel)
            }
        }
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
    // Önizleme için geçici ViewModel oluştur
    LoginView(viewModel: LoginViewModel())
} 