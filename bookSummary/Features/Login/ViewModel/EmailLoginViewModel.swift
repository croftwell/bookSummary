import Foundation
import Combine
import SwiftUI // LocalizedStringKey için
import FirebaseAuth // Firebase Auth import edildi

class EmailLoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoggingIn = false // Aktivite göstergesi için
    @Published var errorMessage: String? // Genel hata mesajı (Firebase vb.)
    
    // Alan bazlı validasyon ve hatalar
    @Published var didAttemptLogin = false // Giriş denemesi yapıldı mı?
    @Published var isEmailValid = true
    @Published var isPasswordValid = true
    @Published var emailErrorMessage: String? // Lokalize anahtar veya metin
    @Published var passwordErrorMessage: String? // Lokalize anahtar veya metin

    // Hata durumunda odaklanılacak alan isteği (View bunu dinleyecek)
    @Published var fieldToFocus: EmailLoginView.LoginField? = nil
    
    // Başarı closure'ı
    private var onAuthenticationSuccess: (() -> Void)?
    
    // ViewModel'i inject etmek ve başarı closure'ını almak için init
    init(onAuthenticationSuccess: (() -> Void)?) {
        self.onAuthenticationSuccess = onAuthenticationSuccess
    }

    // Giriş fonksiyonu (şimdilik sadece validasyon)
    func login() {
        didAttemptLogin = true
        errorMessage = nil // Önceki genel hatayı temizle
        
        // Yerel validasyon (boşluk, format vs.)
        guard validateFields() else {
            // Odaklanma eklendi
            if !isEmailValid {
                fieldToFocus = .email
            } else if !isPasswordValid {
                fieldToFocus = .password
            }
            print("Yerel validasyon başarısız.")
            return
        }
        
        // Firebase isteğinden ÖNCE klavyeyi kapat
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        isLoggingIn = true
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            // Hata varsa işle
            if let error = error {
                self.handleAuthError(error)
                return
            }
            
            // Kullanıcı yoksa (beklenmedik durum)
            guard let user = authResult?.user else {
                 DispatchQueue.main.async {
                    self.isLoggingIn = false
                    self.errorMessage = "error_generic_login_failed"
                 }
                 return
            }
            
            // Başarılı giriş
            DispatchQueue.main.async {
                print("Firebase girişi başarılı: \(user.uid)")
                self.isLoggingIn = false
                // Klavyeyi kapat
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                // Küçük bir gecikmeyle ana akışı devam ettir (Bu kalabilir veya kaldırılabilir, Coordinator yönetirse daha iyi)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { 
                    self.onAuthenticationSuccess?() // Yeni closure'ı çağır
                }
            }
        }
    }

    // Alanları valide et ve hata mesajlarını ayarla
    @discardableResult // Dönüş değeri kullanılmayabilir
    private func validateFields() -> Bool {
        // E-posta validasyonu
        if email.isEmpty {
            isEmailValid = false
            emailErrorMessage = "error_email_empty" // Lokalize anahtar
        } else if !isValidEmail(email) { // Basit e-posta format kontrolü
            isEmailValid = false
            emailErrorMessage = "error_email_invalid"
        } else {
            isEmailValid = true
            emailErrorMessage = nil
        }
        
        // Şifre validasyonu
        if password.isEmpty {
            isPasswordValid = false
            passwordErrorMessage = "error_password_empty"
        } else if password.count < 6 { // Signup ile aynı kural
            isPasswordValid = false
            passwordErrorMessage = "error_password_short"
        } else {
            isPasswordValid = true
            passwordErrorMessage = nil
        }
        
        return isEmailValid && isPasswordValid
    }
    
    // Basit E-posta Format Kontrolü (Daha kapsamlı bir regex kullanılabilir)
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    // Firebase Hata İşleme
    private func handleAuthError(_ error: Error) {
        DispatchQueue.main.async {
            self.isLoggingIn = false
            // Hata kodunu almak için modern yöntem
            guard let authError = error as? AuthErrorCode else {
                // Firebase dışı veya cast edilemeyen hata
                self.errorMessage = "error_generic_login_failed"
                print("Bilinmeyen Auth Hatası: \(error.localizedDescription)")
                return
            }
            
            // Artık authError.code enum'unu kullanabiliriz
            switch authError.code {
            case .wrongPassword:
                self.errorMessage = "error_wrong_password"
                self.isPasswordValid = false
                self.fieldToFocus = .password // Şifreye odaklan
            case .invalidEmail:
                self.errorMessage = "error_email_invalid"
                self.isEmailValid = false
                self.fieldToFocus = .email // Email'e odaklan
            case .userNotFound, .userDisabled:
                self.errorMessage = "error_user_not_found"
                self.isEmailValid = false 
                self.fieldToFocus = .email // Email'e odaklan
            case .networkError:
                self.errorMessage = "error_network_error"
            default:
                self.errorMessage = "error_generic_login_failed"
            }
            print("Firebase Auth Hatası: \(error.localizedDescription)")
        }
    }

    // Coordinator veya diğer servislerle iletişim için Subject'ler veya delegate'ler eklenebilir
} 