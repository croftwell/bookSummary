import Foundation
import Combine
import SwiftUI
import FirebaseAuth

class EmailLoginViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var email = ""
    @Published var password = ""
    @Published var isLoggingIn = false
    
    // Alan bazlı doğrulama
    @Published var didAttemptLogin = false
    @Published var isEmailValid = true
    @Published var emailErrorMessage: String?
    @Published var isPasswordValid = true
    @Published var passwordErrorMessage: String?
    
    // Hata durumunda odaklanılacak alan
    @Published var fieldToFocus: EmailLoginView.LoginField?
    
    // MARK: - Closures for Coordinator
    private var onAuthenticationSuccess: (() -> Void)?
    private var onErrorOccurred: ((String, LoginViewModel.AlertType) -> Void)?
    
    init(
        onAuthenticationSuccess: (() -> Void)?,
        onErrorOccurred: ((String, LoginViewModel.AlertType) -> Void)?
    ) {
        self.onAuthenticationSuccess = onAuthenticationSuccess
        self.onErrorOccurred = onErrorOccurred
    }
    
    // MARK: - Public Methods
    
    func login() {
        didAttemptLogin = true
        
        guard validateFields() else {
            focusOnFirstInvalidField()
            return
        }
        
        hideKeyboard()
        isLoggingIn = true
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoggingIn = false
                
                if let error = error {
                    self.handleAuthError(error)
                    return
                }
                
                guard authResult?.user != nil else {
                    self.onErrorOccurred?("error_generic_login_failed", .error)
                    return
                }
                
                self.onAuthenticationSuccess?()
            }
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func validateFields() -> Bool {
        isEmailValid = !email.isEmpty && isValidEmailFormat(email)
        emailErrorMessage = isEmailValid ? nil : (email.isEmpty ? "error_email_empty" : "error_email_invalid")
        
        isPasswordValid = !password.isEmpty && password.count >= 6
        passwordErrorMessage = isPasswordValid ? nil : (password.isEmpty ? "error_password_empty" : "error_password_short")
        
        return isEmailValid && isPasswordValid
    }
    
    private func focusOnFirstInvalidField() {
        if !isEmailValid {
            fieldToFocus = .email
        } else if !isPasswordValid {
            fieldToFocus = .password
        }
    }
    
    private func isValidEmailFormat(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func handleAuthError(_ error: Error) {
        guard let authError = error as? AuthErrorCode else {
            onErrorOccurred?("error_generic_login_failed", .error)
            return
        }
        
        var errorKey = "error_generic_login_failed"
        switch authError.code {
        case .wrongPassword:
            errorKey = "error_wrong_password"
            isPasswordValid = false
            passwordErrorMessage = nil // Genel hata mesajı alert'te gösterilecek
            fieldToFocus = .password
        case .invalidEmail, .userNotFound, .userDisabled:
            errorKey = "error_user_not_found" // Daha genel bir mesaj
            isEmailValid = false
            emailErrorMessage = nil
            fieldToFocus = .email
        case .networkError:
            errorKey = "error_network_error"
        default:
            break
        }
        
        onErrorOccurred?(errorKey, .error)
    }
}
