import SwiftUI

struct AuthenticationSheetView: View {
    
    @ObservedObject var loginViewModel: LoginViewModel
    
    // View içinde oluşturulan ve inject edilen alt ViewModel'lar
    @StateObject private var signupViewModel: SignupViewModel
    @StateObject private var emailLoginViewModel: EmailLoginViewModel
    
    // Init metodu ViewModel'ları loginViewModel ile başlatır
    init(loginViewModel: LoginViewModel) {
        self.loginViewModel = loginViewModel
        let onAuthSuccess = loginViewModel.requestCompleteAuthentication
        
        self._signupViewModel = StateObject(wrappedValue: SignupViewModel(
            onAuthenticationSuccess: onAuthSuccess
        ))
        self._emailLoginViewModel = StateObject(wrappedValue: EmailLoginViewModel(
            onAuthenticationSuccess: onAuthSuccess
        ))
    }
    
    var body: some View {
        // Alert'i göstermek için ZStack eklendi
        ZStack(alignment: .top) {
            // Mevcut içerik Group ile sarmalanıyor
            Group { 
                switch loginViewModel.currentSheetMode {
                case .signup:
                    // Inject edilen signupViewModel'i kullan
                    SignupView(
                        viewModel: signupViewModel, // Inject viewModel
                        onLoginTapped: loginViewModel.switchToLoginMode,
                        onCloseTapped: loginViewModel.dismissSheet
                    )
                case .emailLogin:
                    // Inject edilen emailLoginViewModel'i kullan
                    EmailLoginView(
                        viewModel: emailLoginViewModel,
                        onSignupTapped: loginViewModel.switchToSignupMode,
                        onCloseTapped: loginViewModel.dismissSheet
                    )
                    .environmentObject(loginViewModel) // Şifremi unuttum butonu için
                case .none: 
                    EmptyView()
                }
            }
            // ForgotPassword sheet'i Group'a eklenmeli, ZStack'e değil.
            // Ancak sheet yapısı ZStack ile tam uyumlu olmayabilir.
            // Şimdilik Group'a ekleyelim. Gerekirse sonra düzeltiriz.
            .sheet(isPresented: $loginViewModel.isPresentingForgotPasswordSheet) {
                 // onCompletion closure'ı başarı durumunu alacak şekilde güncellendi
                 let fpViewModel = ForgotPasswordViewModel(
                     onCompletion: { success in 
                         loginViewModel.dismissForgotPasswordSheet(success: success)
                     }
                 )
                 ForgotPasswordView(
                     viewModel: fpViewModel,
                     onCloseTapped: { fpViewModel.dismiss() } 
                 )
             }
            
            // --- Custom Alert Gösterimi (Buraya taşındı) ---
            if loginViewModel.isShowingAlert, let messageKey = loginViewModel.alertMessage {
                CustomAlertView(
                    message: String(localized: .init(messageKey), table: "Auth"), 
                    type: loginViewModel.alertType, 
                    dismissAction: loginViewModel.dismissAlert
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                // .zIndex(1) // Gerekirse alert'in en üstte olmasını sağlamak için
            }
        }
    }
}

#Preview {
    let previewViewModel = LoginViewModel()
    // Preview'da alert'i test etmek için:
    // previewViewModel.isShowingAlert = true
    // previewViewModel.alertMessage = "forgot_password_success_message" 
    // previewViewModel.alertType = .success
    previewViewModel.currentSheetMode = .emailLogin
    return AuthenticationSheetView(loginViewModel: previewViewModel)
        .environmentObject(previewViewModel) // EmailLoginView'ın ihtiyacı var
} 