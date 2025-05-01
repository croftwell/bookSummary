import SwiftUI

struct AuthenticationSheetView: View {
    
    @ObservedObject var loginViewModel: LoginViewModel
    
    // View içinde oluşturulan ve inject edilen alt ViewModel'lar
    @StateObject private var signupViewModel: SignupViewModel
    @StateObject private var emailLoginViewModel: EmailLoginViewModel
    
    // Init metodu ViewModel'ları loginViewModel ile başlatır
    init(loginViewModel: LoginViewModel) {
        self.loginViewModel = loginViewModel
        // StateObject'leri burada başlatıyoruz
        self._signupViewModel = StateObject(wrappedValue: SignupViewModel(
            onAuthenticationSuccess: loginViewModel.requestCompleteAuthentication
        ))
        self._emailLoginViewModel = StateObject(wrappedValue: EmailLoginViewModel(
            onAuthenticationSuccess: loginViewModel.requestCompleteAuthentication
        ))
    }
    
    var body: some View {
        // NavigationView artık gerekli olmayabilir, çünkü her view kendi hatasını yönetiyor
        // NavigationView {
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
                        viewModel: emailLoginViewModel, // Inject viewModel
                        onSignupTapped: loginViewModel.switchToSignupMode,
                        onCloseTapped: loginViewModel.dismissSheet 
                    )
                case .forgotPassword:
                    Text("Şifremi Unuttum Formu Buraya Gelecek")
                case .none: 
                    EmptyView()
                }
            }
        // }
    }
}

#Preview {
    let previewViewModel = LoginViewModel()
    previewViewModel.currentSheetMode = .signup
    return AuthenticationSheetView(loginViewModel: previewViewModel)
} 