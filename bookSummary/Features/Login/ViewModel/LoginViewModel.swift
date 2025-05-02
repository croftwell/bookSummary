import Foundation
import Combine
import SwiftUI // Color ve AlertType için

class LoginViewModel: ObservableObject {
    
    // Ana Kimlik Doğrulama Sheet Modları
    enum AuthenticationSheetMode {
        case none, signup, emailLogin // forgotPassword kaldırıldı
    }
    
    // Özel Alert Türü
    enum AlertType {
        case success
        case error
        // Gerekirse info, warning eklenebilir
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            }
        }
        // Gerekirse ikon da eklenebilir
    }
    
    // Hangi ana sheet modunun aktif olduğunu tutar
    @Published var currentSheetMode: AuthenticationSheetMode = .none
    // Şifremi Unuttum sheet'i için ayrı state
    @Published var isPresentingForgotPasswordSheet = false
    
    // Özel Alert State'leri
    @Published var isShowingAlert = false
    @Published var alertMessage: String? // Lokalize anahtar
    @Published var alertType: AlertType = .success // Varsayılan
    
    var completeAuthenticationRequested: (() -> Void)? 
    private var alertTimer: AnyCancellable? // Alert'i otomatik kapatmak için

    // --- Ana Sheet Modunu Ayarlama --- 
    func requestShowSignup() {
        // Başka bir sheet açık değilken aç
        if currentSheetMode == .none && !isPresentingForgotPasswordSheet {
            currentSheetMode = .signup
        }
    }
    
    func requestShowEmailLogin() {
        if currentSheetMode == .none && !isPresentingForgotPasswordSheet {
            currentSheetMode = .emailLogin
        }
    }
    
    // --- Şifremi Unuttum Sheet Yönetimi --- 
    func requestShowForgotPassword() {
        // Ana sheet'i kapatma mantığı kaldırıldı
        if !isPresentingForgotPasswordSheet { // Zaten açıksa tekrar açma
             isPresentingForgotPasswordSheet = true
        }
    }
    
    // ForgotPasswordViewModel tarafından onCompletion ile çağrılacak
    func dismissForgotPasswordSheet(success: Bool) {
        isPresentingForgotPasswordSheet = false
        
        // Sadece başarılı durumda alert göster
        if success {
            showAlert(messageKey: "forgot_password_success_message", type: .success)
        }
    }
    
    // --- Ana Sheet İçinde Mod Değiştirme --- (Bunlar aynı kalıyor)
    func switchToLoginMode() {
        currentSheetMode = .emailLogin
    }
    
    func switchToSignupMode() {
        currentSheetMode = .signup
    }
    
    // --- Ana Sheet Kapatma ---
    func dismissSheet() {
        currentSheetMode = .none
    }
    
    // --- Özel Alert Yönetimi --- 
    func showAlert(messageKey: String, type: AlertType, duration: TimeInterval = 3.0) {
        alertMessage = messageKey
        alertType = type
        isShowingAlert = true
        
        // Eski timer'ı iptal et (varsa)
        alertTimer?.cancel()
        
        // Yeni timer başlat
        alertTimer = Just(())
            .delay(for: .seconds(duration), scheduler: RunLoop.main)
            .sink { [weak self] in
                self?.dismissAlert()
            }
    }
    
    func dismissAlert() {
        alertTimer?.cancel() // Timer'ı durdur
        alertTimer = nil
        withAnimation { // Kapanış animasyonu için
             isShowingAlert = false
        }
        // Mesajı biraz gecikmeyle temizle ki animasyon bitince kaybolsun
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { 
            self.alertMessage = nil
        }
    }
    
    // --- Kimlik Doğrulama Tamamlama ---
    func requestCompleteAuthentication() {
        dismissSheet()
        // dismissForgotPasswordSheet(success: false) // Başarıyı burada belirtmeye gerek yok
        if isPresentingForgotPasswordSheet { isPresentingForgotPasswordSheet = false } 
        dismissAlert() // Varsa alert'i de kapat
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { 
            self.completeAuthenticationRequested?()
        }
    }
} 