import SwiftUI

/// Alışkanlık seçimi akışını yöneten coordinator.
class HabitsCoordinator: Coordinator, ObservableObject {
    
    /// Akış tamamlandığında çağrılacak olan closure.
    var didFinishHabits: (() -> Void)?
    
    func start() -> AnyView {
        let viewModel = HabitsViewModel()
        
        // ViewModel'den gelen "tamamlandı" olayını dinle.
        viewModel.onComplete = { [weak self] in
            self?.finishHabits()
        }
        
        let view = HabitsView(viewModel: viewModel)
        return AnyView(view)
    }
    
    /// Akışı sonlandırır ve üst katmanı (genellikle App) bilgilendirir.
    private func finishHabits() {
        // TODO: Kullanıcının seçtiği alışkanlıkları kaydetme işlemi burada yapılabilir
        // veya ViewModel içinde halledilebilir.
        didFinishHabits?()
    }
}
