import Foundation
import Combine
import SwiftUI

class LoginViewModel: ObservableObject {
    
    // MARK: - Enums
    
    /// Hangi kimlik doğrulama sheet'inin gösterileceğini belirler.
    enum AuthenticationSheetMode {
        case none, signup, emailLogin
    }
    
    /// Özel alert bildiriminin türünü belirler.
    enum AlertType {
        case success
        case error
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            }
        }
    }
    
    // MARK: - Published Properties
    
    /// Hangi ana sheet modunun aktif olduğunu tutar.
    @Published var currentSheetMode: AuthenticationSheetMode = .none
    
    /// "Şifremi Unuttum" sheet'inin gösterilip gösterilmeyeceğini kontrol eder.
    @Published var isPresentingForgotPasswordSheet = false
    
    /// Özel alert'in gösterilip gösterilmeyeceğini kontrol eder.
    @Published var isShowingAlert = false
    
    /// Alert'te gösterilecek lokalize metin anahtarı.
    @Published var alertMessage: String?
    
    /// Alert'in türü (başarı/hata).
    @Published var alertType: AlertType = .success
    
    /// `isSheetPresented` computed property'si, `LoginView`'daki `.sheet` modifier'ını basitleştirir.
    var isSheetPresented: Bool {
        get { currentSheetMode != .none }
        set { if !newValue { dismissSheet() } }
    }
    
    // MARK: - Closures for Coordinator
    
    /// Tüm kimlik doğrulama akışı bittiğinde coordinator'ı bilgilendirmek için.
    var authenticationCompleted: (() -> Void)?
    
    private var alertTimer: AnyCancellable?
    
    // MARK: - Sheet Management
    
    func requestShowSignup() {
        if currentSheetMode == .none && !isPresentingForgotPasswordSheet {
            currentSheetMode = .signup
        }
    }
    
    func requestShowForgotPassword() {
        if !isPresentingForgotPasswordSheet {
            isPresentingForgotPasswordSheet = true
        }
    }
    
    func dismissForgotPasswordSheet(success: Bool) {
        isPresentingForgotPasswordSheet = false
        if success {
            showAlert(messageKey: "forgot_password_success_message", type: .success)
        }
    }
    
    func switchToLoginMode() {
        currentSheetMode = .emailLogin
    }
    
    func switchToSignupMode() {
        currentSheetMode = .signup
    }
    
    func dismissSheet() {
        currentSheetMode = .none
    }
    
    // MARK: - Alert Management
    
    func showAlert(messageKey: String, type: AlertType, duration: TimeInterval = 4.0) {
        alertMessage = messageKey
        alertType = type
        isShowingAlert = true
        
        alertTimer?.cancel()
        alertTimer = Just(())
            .delay(for: .seconds(duration), scheduler: RunLoop.main)
            .sink { [weak self] in self?.dismissAlert() }
    }
    
    func dismissAlert() {
        alertTimer?.cancel()
        alertTimer = nil
        withAnimation {
            isShowingAlert = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.alertMessage = nil
        }
    }
    
    // MARK: - Authentication Flow Completion
    
    func requestCompleteAuthentication() {
        dismissSheet()
        if isPresentingForgotPasswordSheet { isPresentingForgotPasswordSheet = false }
        dismissAlert()
        
        // Coordinator'ı bilgilendirmeden önce UI'ın kapanması için küçük bir gecikme
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.authenticationCompleted?()
        }
    }
}
