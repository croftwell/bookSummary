import SwiftUI

struct AuthenticationSheetView: View {
    
    @ObservedObject var loginViewModel: LoginViewModel
    
    @StateObject private var signupViewModel: SignupViewModel
    @StateObject private var emailLoginViewModel: EmailLoginViewModel
    
    init(loginViewModel: LoginViewModel) {
        self.loginViewModel = loginViewModel
        
        // Alt ViewModel'ları, üst ViewModel'in metodlarını çağıracak şekilde başlat.
        let onAuthSuccess = loginViewModel.requestCompleteAuthentication
        
        self._signupViewModel = StateObject(wrappedValue: SignupViewModel(
            onAuthenticationSuccess: onAuthSuccess
        ))
        
        self._emailLoginViewModel = StateObject(wrappedValue: EmailLoginViewModel(
            onAuthenticationSuccess: onAuthSuccess,
            onErrorOccurred: { messageKey, type in
                // HATA DÜZELTMESİ: Closure olarak atamak yerine,
                // metodu doğrudan `loginViewModel` üzerinden çağırıyoruz.
                // Bu, argüman etiketlerini ve varsayılan parametreleri korur.
                loginViewModel.showAlert(messageKey: messageKey, type: type)
            }
        ))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            mainContent
                .sheet(isPresented: $loginViewModel.isPresentingForgotPasswordSheet) {
                    forgotPasswordSheet
                }
            
            alertOverlay
        }
    }
    
    /// Sheet'in ana içeriğini (Giriş veya Kaydol) gösterir.
    @ViewBuilder
    private var mainContent: some View {
        switch loginViewModel.currentSheetMode {
        case .signup:
            SignupView(
                viewModel: signupViewModel,
                onLoginTapped: loginViewModel.switchToLoginMode,
                onCloseTapped: loginViewModel.dismissSheet
            )
        case .emailLogin:
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
    
    /// "Şifremi Unuttum" sheet'ini oluşturur.
    private var forgotPasswordSheet: some View {
        let fpViewModel = ForgotPasswordViewModel(
            onCompletion: { success in
                loginViewModel.dismissForgotPasswordSheet(success: success)
            }
        )
        return ForgotPasswordView(
            viewModel: fpViewModel,
            onCloseTapped: { fpViewModel.dismiss() }
        )
    }
    
    /// Özel alert bildirimini gösterir.
    @ViewBuilder
    private var alertOverlay: some View {
        if loginViewModel.isShowingAlert, let messageKey = loginViewModel.alertMessage {
            CustomAlertView(
                message: String(localized: .init(messageKey), table: "Auth"),
                type: loginViewModel.alertType,
                dismissAction: loginViewModel.dismissAlert
            )
            .transition(.move(edge: .top).combined(with: .opacity))
            .zIndex(1) // Diğer içeriklerin üzerinde olmasını sağlar.
        }
    }
}


#Preview {
    let previewViewModel = LoginViewModel()
    // previewViewModel.currentSheetMode = .emailLogin
    previewViewModel.currentSheetMode = .signup
    
    // Alert'i test etmek için:
    // previewViewModel.showAlert(messageKey: "forgot_password_success_message", type: .success)
    
    return AuthenticationSheetView(loginViewModel: previewViewModel)
        .environmentObject(previewViewModel)
}
