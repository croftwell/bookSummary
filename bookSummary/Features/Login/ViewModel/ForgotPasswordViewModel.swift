import Foundation
import Combine
import FirebaseAuth
import SwiftUI // LocalizedStringKey için

class ForgotPasswordViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var isSending = false
    @Published var errorMessage: String? // Hata mesajı anahtarı veya metni
    @Published var successMessage: String? // Bu kaldırılabilir veya sadece loglama için tutulabilir
    
    // Validasyon
    @Published var didAttemptSend = false
    @Published var isEmailValid = true
    @Published var emailErrorMessage: String? // Lokalize anahtar
    
    // İşlem tamamlandığında çağrılacak closure (başarı durumu ile)
    private var onCompletion: ((Bool) -> Void)?
    
    // Odaklanma için (View'a eklenecek)
    @Published var fieldToFocus: ForgotPasswordView.Field? = nil
    
    init(onCompletion: ((Bool) -> Void)?) {
        self.onCompletion = onCompletion
    }
    
    // Şifre sıfırlama e-postası gönderme
    func sendPasswordResetEmail() {
        didAttemptSend = true
        errorMessage = nil
        successMessage = nil
        
        guard validateEmail() else {
            fieldToFocus = .email // E-posta alanına odaklan
            return
        }
        
        isSending = true
        
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isSending = false
                if let error = error {
                    self.handleAuthError(error)
                    // Hata durumunda sheet kapanmayacak, kullanıcı X'e basacak
                    // self.onCompletion?(false) // Hata durumunda otomatik kapatma yok
                } else {
                    print("Şifre sıfırlama e-postası gönderildi: \(self.email)")
                    // Yerel mesaj yerine başarıyla tamamlandığını bildir
                    // self.successMessage = "forgot_password_success_message"
                    self.onCompletion?(true) // Başarıyla tamamlandı
                }
            }
        }
    }
    
    // Email validasyonu
    @discardableResult
    private func validateEmail() -> Bool {
        if email.isEmpty {
            isEmailValid = false
            emailErrorMessage = "error_email_empty"
        } else if !isValidEmailFormat(email) { 
            isEmailValid = false
            emailErrorMessage = "error_email_invalid"
        } else {
            isEmailValid = true
            emailErrorMessage = nil
        }
        return isEmailValid
    }
    
    private func isValidEmailFormat(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // Firebase Hata İşleme
    private func handleAuthError(_ error: Error) {
        if let authError = error as? AuthErrorCode {
            switch authError.code {
            case .userNotFound:
                self.errorMessage = "error_user_not_found"
                self.isEmailValid = false // Email'i geçersiz say
                self.fieldToFocus = .email // Email'e odaklan
            case .invalidEmail:
                self.errorMessage = "error_email_invalid"
                self.isEmailValid = false
                self.fieldToFocus = .email
            case .networkError:
                self.errorMessage = "error_network_error"
            default:
                self.errorMessage = "error_generic_auth_failed"
            }
        } else {
            self.errorMessage = "error_generic_auth_failed"
        }
        print("Firebase Auth Hatası (Password Reset): \(error.localizedDescription)")
    }
    
    // View kapatıldığında çağrılacak (X butonundan)
    func dismiss() {
        onCompletion?(false) // Başarısız veya manuel kapatma
    }
}

// ForgotPasswordView içinde tanımlanacak:
// enum Field: Hashable { case email } 