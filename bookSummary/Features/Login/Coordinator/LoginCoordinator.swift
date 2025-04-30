import SwiftUI
import Combine

// Coordinator protokolü (Merkezi bir yerde tanımlı varsayılıyor)
// protocol Coordinator { func start() -> AnyView }

class LoginCoordinator: Coordinator, ObservableObject {
    
    // Alt akışları gösterme durumları ViewModel'e taşındı
    // @Published var isPresentingEmailLoginSheet = false
    // @Published var isPresentingForgotPasswordSheet = false
    
    var didFinishAuth: (() -> Void)?
    private var cancellables = Set<AnyCancellable>()
    
    func start() -> AnyView {
        let viewModel = LoginViewModel()
        
        // ViewModel'den gelen istekleri dinle (Artık sheet gösterme için değil)
        // Başarılı kimlik doğrulama isteği gibi şeyler için kullanılabilir
        viewModel.completeAuthenticationRequested = { [weak self] in
             self?.completeAuthentication()
        }
        
        // LoginView'ı oluştur ve ViewModel'i inject et
        let view = LoginView(viewModel: viewModel)
            // Sheet modifier'ları View'a taşındı
            // .sheet(isPresented: $isPresentingEmailLoginSheet) { ... }
            // .sheet(isPresented: $isPresentingForgotPasswordSheet) { ... }

        return AnyView(view)
    }
    
    func completeAuthentication() {
        // Tüm sheet'leri kapat (gerekirse) -> Durumlar ViewModel'de olduğu için 
        // Coordinator'ın doğrudan kapatmasına gerek kalmadı. 
        // Sadece üst Coordinator'a bildirim yeterli.
        didFinishAuth?()
    }
} 