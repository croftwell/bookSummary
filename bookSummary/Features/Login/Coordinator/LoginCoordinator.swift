import SwiftUI
import Combine

/// Kimlik doğrulama akışını (Giriş, Kayıt, Şifre Sıfırlama) yöneten coordinator.
class LoginCoordinator: Coordinator, ObservableObject {
    
    /// Kimlik doğrulama başarıyla tamamlandığında çağrılacak olan closure.
    var didFinishAuth: (() -> Void)?
    
    private var cancellables = Set<AnyCancellable>()
    
    func start() -> AnyView {
        // Bu akışın ana ViewModel'i oluşturulur.
        let viewModel = LoginViewModel()
        
        // ViewModel'den gelen "kimlik doğrulama tamamlandı" isteğini dinle.
        viewModel.authenticationCompleted = { [weak self] in
            self?.finishAuthentication()
        }
        
        // LoginView, ana ViewModel ile başlatılır.
        // LoginView, kendi içindeki sheet'leri ve alt akışları bu ViewModel aracılığıyla yönetir.
        let view = LoginView(viewModel: viewModel)
        
        return AnyView(view)
    }
    
    /// Akışı sonlandırır ve üst katmanı (genellikle App) bilgilendirir.
    private func finishAuthentication() {
        didFinishAuth?()
    }
}
