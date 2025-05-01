import Foundation
import Combine

class LoginViewModel: ObservableObject {
    
    // Sheet Modları için Enum
    enum AuthenticationSheetMode {
        case none, signup, emailLogin, forgotPassword
    }
    
    // Hangi sheet modunun aktif olduğunu tutar
    @Published var currentSheetMode: AuthenticationSheetMode = .none
    
    // Coordinator tarafından set edilecek closure'lar
    var completeAuthenticationRequested: (() -> Void)? 

    // --- Sheet Modunu Ayarlama Fonksiyonları --- 
    
    func requestShowSignup() {
        currentSheetMode = .signup
    }
    
    func requestShowEmailLogin() {
        currentSheetMode = .emailLogin
    }
    
    func requestShowForgotPassword() {
        currentSheetMode = .forgotPassword
    }
    
    // --- Sheet İçinde Mod Değiştirme Fonksiyonları ---
    func switchToLoginMode() {
        currentSheetMode = .emailLogin
    }
    
    func switchToSignupMode() {
        currentSheetMode = .signup
    }
    
    // Sheet'i kapatmak için (Sheet içinden veya dışından çağrılabilir)
    func dismissSheet() {
        currentSheetMode = .none
    }
    
    // --- Kimlik Doğrulama Tamamlama ---
    // Başarılı Apple/Google/Email girişi veya kayıt sonrası bu çağrılabilir
    func requestCompleteAuthentication() {
        // Önce sheet'i kapat, sonra tamamlama işlemini tetikle
        dismissSheet() 
        // Belki küçük bir gecikme gerekebilir?
        // DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.completeAuthenticationRequested?()
        // }
    }
} 