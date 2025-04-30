import SwiftUI

// Coordinator protokolü varsayılıyor

class HabitsCoordinator: Coordinator, ObservableObject {
    
    var didFinishHabits: (() -> Void)?
    
    func start() -> AnyView {
        let viewModel = HabitsViewModel()
        
        // ViewModel ile bağlantılar (örn. bitirme isteği)
        viewModel.onComplete = { [weak self] in
            self?.finishHabits()
        }
        
        let view = HabitsView(viewModel: viewModel)
        return AnyView(view)
    }
    
    private func finishHabits() {
        didFinishHabits?()
    }
} 