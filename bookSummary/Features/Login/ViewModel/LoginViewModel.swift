import Foundation
import Combine

class LoginViewModel: ObservableObject {
    
    // Sheet durumları ViewModel'de yönetilecek
    @Published var isPresentingSignupSheet = false
    @Published var isPresentingEmailLoginSheet = false
    @Published var isPresentingForgotPasswordSheet = false
    
    // Coordinator tarafından set edilecek closure'lar
    // var showEmailLoginRequested: (() -> Void)? // Kaldırıldı
    // var showForgotPasswordRequested: (() -> Void)? // Kaldırıldı
    var completeAuthenticationRequested: (() -> Void)? 

    // --- İstek Fonksiyonları --- 
    
    func requestShowSignup() {
        isPresentingSignupSheet = true
    }
    
    func requestShowEmailLogin() {
        // showEmailLoginRequested?() // Kaldırıldı
        isPresentingEmailLoginSheet = true // State'i doğrudan güncelle
    }
    
    func requestShowForgotPassword() {
        // showForgotPasswordRequested?() // Kaldırıldı
        isPresentingForgotPasswordSheet = true // State'i doğrudan güncelle
    }
    
    // TODO: Başarılı Apple/Google/Email girişi sonrası bu çağrılabilir
    func requestCompleteAuthentication() {
        completeAuthenticationRequested?()
    }
} 