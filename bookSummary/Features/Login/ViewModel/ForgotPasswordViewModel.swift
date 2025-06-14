import Foundation
import Combine
import FirebaseAuth

class ForgotPasswordViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var email = ""
    @Published var isSending = false
    
    @Published var didAttemptSend = false
    @Published var isEmailValid = true
    @Published var emailErrorMessage: String?
    @Published var errorMessage: String? // Genel sunucu hataları için
    
    @Published var isSuccess = false
    @Published var fieldToFocus: ForgotPasswordView.Field?
    
    // MARK: - Closures for Coordinator
    private var onCompletion: ((_ success: Bool) -> Void)?
    
    init(onCompletion: ((Bool) -> Void)?) {
        self.onCompletion = onCompletion
    }
    
    // MARK: - Public Methods
    
    func sendPasswordResetEmail() {
        didAttemptSend = true
        errorMessage = nil
        
        guard validateEmail() else {
            fieldToFocus = .email
            return
        }
        
        isSending = true
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isSending = false
                if let error = error {
                    self.handleAuthError(error)
                } else {
                    self.isSuccess = true
                    self.onCompletion?(true)
                }
            }
        }
    }
    
    /// View kapatıldığında (örneğin X butonuna basıldığında) çağrılır.
    func dismiss() {
        onCompletion?(false)
    }
    
    // MARK: - Private Helper Methods
    
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
        return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
    
    private func handleAuthError(_ error: Error) {
        if let authError = error as? AuthErrorCode {
            switch authError.code {
            case .userNotFound:
                errorMessage = "error_user_not_found"
            case .invalidEmail:
                errorMessage = "error_email_invalid"
            case .networkError:
                errorMessage = "error_network_error"
            default:
                errorMessage = "error_generic_auth_failed"
            }
        } else {
            errorMessage = "error_generic_auth_failed"
        }
        isEmailValid = false // Hata durumunda alanı geçersiz say
        fieldToFocus = .email
    }
}
