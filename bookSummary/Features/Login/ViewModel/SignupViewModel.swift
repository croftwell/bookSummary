import Foundation
import Combine
import FirebaseAuth
import SwiftUI

class SignupViewModel: ObservableObject {
    
    typealias FocusableField = AnyHashable
    
    // MARK: - Published Properties
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    
    // Doğrulama Durumları
    @Published var isNameValid = true
    @Published var nameErrorMessage: String?
    @Published var isEmailValid = true
    @Published var emailErrorMessage: String?
    @Published var isPasswordValid = true
    @Published var passwordErrorMessage: String?
    
    // Genel Durumlar
    @Published var didAttemptSignup = false
    @Published var genericErrorMessage: String?
    @Published var isLoading = false
    @Published var fieldToFocus: FocusableField?
    
    // MARK: - Closures for Coordinator
    private var onAuthenticationSuccess: (() -> Void)?
    
    init(onAuthenticationSuccess: (() -> Void)?) {
        self.onAuthenticationSuccess = onAuthenticationSuccess
    }
    
    // MARK: - Public Methods
    
    func signUpWithEmail() {
        didAttemptSignup = true
        genericErrorMessage = nil
        
        guard validateAllFields() else {
            focusOnFirstInvalidField()
            return
        }
        
        hideKeyboard()
        isLoading = true
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                self.handleAuthError(error)
                return
            }
            
            guard let user = authResult?.user else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.genericErrorMessage = "error_generic_signup_failed"
                }
                return
            }
            
            self.updateUserProfile(for: user)
        }
    }
    
    func resetFocusRequest() {
        fieldToFocus = nil
    }
    
    // MARK: - Private Helper Methods
    
    private func updateUserProfile(for user: User) {
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = self.name
        changeRequest.commitChanges { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    // Profil güncelleme hatası genellikle kritik değildir, kullanıcı yine de giriş yapabilir.
                    // Bu durumu loglayabilir veya kullanıcıya opsiyonel bir mesaj gösterebiliriz.
                    print("Profil güncelleme hatası: \(error.localizedDescription)")
                }
                self?.onAuthenticationSuccess?()
            }
        }
    }
    
    private func handleAuthError(_ error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
            guard let authError = error as? AuthErrorCode else {
                self.genericErrorMessage = "error_generic_auth_failed"
                return
            }
            
            switch authError.code {
            case .emailAlreadyInUse:
                self.genericErrorMessage = "error_email_already_in_use"
                self.isEmailValid = false
                self.fieldToFocus = SignupView.Field.email
            case .invalidEmail:
                self.genericErrorMessage = "error_email_invalid"
                self.isEmailValid = false
                self.fieldToFocus = SignupView.Field.email
            case .weakPassword:
                self.genericErrorMessage = "error_weak_password"
                self.isPasswordValid = false
                self.fieldToFocus = SignupView.Field.password
            case .networkError:
                self.genericErrorMessage = "error_network_error"
            default:
                self.genericErrorMessage = "error_generic_auth_failed"
            }
        }
    }
    
    private func validateAllFields() -> Bool {
        // İsim kontrolü
        isNameValid = !name.trimmingCharacters(in: .whitespaces).isEmpty
        nameErrorMessage = isNameValid ? nil : "error_name_empty"
        
        // E-posta kontrolü
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
        
        // Şifre kontrolü
        if password.isEmpty {
            isPasswordValid = false
            passwordErrorMessage = "error_password_empty"
        } else if password.count < 6 {
            isPasswordValid = false
            passwordErrorMessage = "error_password_short"
        } else {
            isPasswordValid = true
            passwordErrorMessage = nil
        }
        
        return isNameValid && isEmailValid && isPasswordValid
    }
    
    private func focusOnFirstInvalidField() {
        if !isNameValid { fieldToFocus = SignupView.Field.name }
        else if !isEmailValid { fieldToFocus = SignupView.Field.email }
        else if !isPasswordValid { fieldToFocus = SignupView.Field.password }
    }
    
    private func isValidEmailFormat(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
