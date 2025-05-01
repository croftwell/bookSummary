import Foundation
import Combine
import FirebaseAuth
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
    
    // LoginViewModel ile iletişim için (başarılı kayıtta çağrılacak)
    private weak var loginViewModel: LoginViewModel?
    
    // ViewModel'i inject etmek için init
    init(loginViewModel: LoginViewModel?) {
        self.loginViewModel = loginViewModel
    }
    
    // Formun format/uzunluk açısından geçerliliği
    var isFormValid: Bool {
        // Bu kontroller artık signUpWithEmail içinde yapılıyor,
        // ama hızlı kontrol için kalabilir.
        validateName(name)
        validateEmail(email)
        validatePassword(password)
        return isNameValid && isEmailValid && isPasswordValid
    }
    
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
        validateName(name)
        validateEmail(email)
        validatePassword(password)
    }

    func signUpWithEmail() {
        didAttemptSignup = true 
        validateAllFields()
        
        guard isNameValid && isEmailValid && isPasswordValid else {
            // İlk geçersiz alana odaklan
            if !isNameValid { fieldToFocus = SignupView.Field.name }
            else if !isEmailValid { fieldToFocus = SignupView.Field.email }
            else if !isPasswordValid { fieldToFocus = SignupView.Field.password }
            return 
        }
        
        isLoading = true
        genericErrorMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            // Hata varsa işle
            if let error = error {
                self.handleAuthError(error)
                return
            }
            
            // Kullanıcı yoksa (beklenmedik durum)
            guard let user = authResult?.user else {
                 DispatchQueue.main.async {
                    self.isLoading = false
                    self.genericErrorMessage = "error_generic_signup_failed"
                 }
                 return
            }
            
            // Kullanıcı oluşturuldu, profilini güncelle
            self.updateUserProfile(user: user)
        }
    }
    
    // Kullanıcı profilini güncelle (isim)
    private func updateUserProfile(user: User) {
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = self.name
        changeRequest.commitChanges { [weak self] error in
            // Profil güncelleme hatası olsa bile kaydı başarılı sayabiliriz.
            // LoginViewModel'i haberdar et.
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    print("Profil güncelleme hatası: \(error.localizedDescription)")
                    // Belki kullanıcıya bilgi verilebilir ama akış devam etmeli
                    // self?.genericErrorMessage = "error_profile_update_failed"
                }
                print("Firebase kaydı ve profil güncelleme başarılı: \(user.uid)")
                self?.didCompleteSignup = true // View'ın kapatılması için state
                self?.loginViewModel?.requestCompleteAuthentication() // Ana akışı devam ettir
            }
        }
    }
    
    // Firebase Hata İşleme
    private func handleAuthError(_ error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
            // Hata kodunu almak için modern yöntem
            guard let authError = error as? AuthErrorCode else {
                // Firebase dışı veya cast edilemeyen hata
                self.genericErrorMessage = "error_generic_auth_failed"
                print("Bilinmeyen Auth Hatası: \(error.localizedDescription)")
                return
            }
            
            // Artık authError.code enum'unu kullanabiliriz
            switch authError.code {
            case .emailAlreadyInUse:
                self.genericErrorMessage = "error_email_already_in_use"
                self.isEmailValid = false // Email alanını geçersiz işaretle
                self.fieldToFocus = SignupView.Field.email // Email alanına odaklan
            case .invalidEmail:
                self.genericErrorMessage = "error_email_invalid"
                self.isEmailValid = false
                self.fieldToFocus = SignupView.Field.email
            case .weakPassword:
                self.genericErrorMessage = "error_weak_password"
                self.isPasswordValid = false // Şifre alanını geçersiz işaretle
                self.fieldToFocus = SignupView.Field.password // Şifre alanına odaklan
            case .networkError:
                self.genericErrorMessage = "error_network_error"
            default:
                self.genericErrorMessage = "error_generic_auth_failed"
            }
            // Hata mesajını alan mesajına da yansıtabiliriz (opsiyonel)
            // if !self.isEmailValid { self.emailErrorMessage = self.genericErrorMessage }
            // if !self.isPasswordValid { self.passwordErrorMessage = self.genericErrorMessage }
            print("Firebase Auth Hatası: \(error.localizedDescription)")
        }
    }
    
    // Odaklanma isteğini sıfırla (Bu kalabilir)
    func resetFocusRequest() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.fieldToFocus = nil
        }
    }
} 