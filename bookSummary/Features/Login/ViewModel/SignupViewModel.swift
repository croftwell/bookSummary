import Foundation
import Combine
import FirebaseAuth // Firebase Auth import edildi
import SwiftUI

class SignupViewModel: ObservableObject {
    
    // Field enum'ı View'da olduğundan AnyHashable kullanalım
    typealias FocusableField = AnyHashable
    
    // Input Alanları
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    
    // Doğrulama Durumları (Başlangıçta geçerli kabul ediliyor)
    @Published var isNameValid = true
    @Published var nameErrorMessage: String? = nil
    @Published var isEmailValid = true
    @Published var emailErrorMessage: String? = nil
    @Published var isPasswordValid = true
    @Published var passwordErrorMessage: String? = nil
    
    // Kaydolma denemesi (sadece format/uzunluk kontrolü için)
    @Published var didAttemptSignup = false 
    
    // Hata durumunda odaklanılacak alan isteği
    @Published var fieldToFocus: FocusableField? = nil
    
    // Genel Hata ve Durum
    @Published var genericErrorMessage: String? = nil
    @Published var isLoading = false
    @Published var didCompleteSignup = false // Kayıt başarılı olursa bunu true yap
    
    // Formun format/uzunluk açısından geçerliliği
    var isFormValid: Bool {
        isNameValid && isEmailValid && isPasswordValid
    }
    
    // init() ve setupValidationBindings kaldırıldı (Anlık doğrulama yok)

    // Doğrulama Fonksiyonları (Hata mesajları anahtar olarak ayarlanacak)
    private func validateName(_ name: String) {
        if name.isEmpty {
            isNameValid = false
            nameErrorMessage = didAttemptSignup ? "error_name_empty" : nil
        } else {
            isNameValid = true
            nameErrorMessage = nil
        }
    }

    private func validateEmail(_ email: String) {
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        if email.isEmpty {
            isEmailValid = false
            emailErrorMessage = didAttemptSignup ? "error_email_empty" : nil
        } else if !emailPredicate.evaluate(with: email) {
            isEmailValid = false
            emailErrorMessage = didAttemptSignup ? "error_email_invalid" : nil
        } else {
            isEmailValid = true
            emailErrorMessage = nil
        }
    }

    private func validatePassword(_ password: String) {
        if password.isEmpty {
            isPasswordValid = false
            passwordErrorMessage = didAttemptSignup ? "error_password_empty" : nil
        } else if password.count < 6 {
            isPasswordValid = false
            passwordErrorMessage = didAttemptSignup ? "error_password_short" : nil
        } else {
            isPasswordValid = true
            passwordErrorMessage = nil
        }
    }
    
    private func validateAllFields() {
        print("validateAllFields çağrıldı") // Debug
        validateName(name)
        validateEmail(email)
        validatePassword(password)
        print("Doğrulama sonrası: isNameValid=\(isNameValid), isEmailValid=\(isEmailValid), isPasswordValid=\(isPasswordValid)") // Debug
    }

    func signUpWithEmail() {
        print("signUpWithEmail çağrıldı")
        
        // 1. Kaydolma denemesini işaretle ve tüm alanları doğrula
        self.didAttemptSignup = true 
        validateAllFields() // Tüm kontrolleri (boşluk, format, uzunluk) yapar
        
        // 2. Genel geçerliliği kontrol et
        // 'isFormatValid' adını 'isFormValid' olarak geri değiştirelim, daha anlamlı.
        print("guard kontrolü öncesi: isFormValid=\(isFormValid)")
        guard isFormValid else {
            print("Form geçersiz, guard bloğuna girildi.")
            // İlk GEÇERSİZ alana odaklan (boş veya format hatası)
            if !isNameValid { fieldToFocus = SignupView.Field.name }
            else if !isEmailValid { fieldToFocus = SignupView.Field.email }
            else if !isPasswordValid { fieldToFocus = SignupView.Field.password }
            print("Geçersiz alan bulundu, odaklanılıyor: \(fieldToFocus?.description ?? "yok")")
            return 
        }
        
        // 3. Form Geçerli -> Firebase
        print("Form geçerli, Firebase'e gönderiliyor...")
        isLoading = true
        genericErrorMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    // Firebase hatasını olduğu gibi gösterelim
                    self.genericErrorMessage = error.localizedDescription
                }
                return
            }
            
            guard let user = authResult?.user else {
                 DispatchQueue.main.async {
                    self.isLoading = false
                    // Anahtarı kullanalım
                    self.genericErrorMessage = "error_generic_signup_failed"
                 }
                 return
            }
            
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = self.name
            changeRequest.commitChanges { [weak self] error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if let _ = error { // Hatayı doğrudan göstermek yerine anahtar kullanalım
                        self?.genericErrorMessage = "error_profile_update_failed"
                        self?.didCompleteSignup = true 
                    } else {
                        print("Firebase kaydı ve profil güncelleme başarılı: \(user.uid)")
                        self?.didCompleteSignup = true
                    }
                }
            }
        }
    }
    
    // Odaklanma isteğini sıfırla (View tarafından çağrılacak)
    func resetFocusRequest() {
        // Küçük bir gecikme ile sıfırlama, onChange'in tekrar tetiklenmesini önler
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.fieldToFocus = nil
        }
    }
} 