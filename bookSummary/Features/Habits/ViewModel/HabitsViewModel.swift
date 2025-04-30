import Foundation
import Combine

class HabitsViewModel: ObservableObject {
    
    // TODO: Kullanıcının seçtiği alışkanlıkları tutacak state (@Published)
    // @Published var selectedHabits: Set<String> = []
    
    var onComplete: (() -> Void)?
    
    // TODO: Alışkanlıkları kaydetme mantığı
    func saveHabits() {
        print("Alışkanlıklar kaydedildi (simülasyon).")
        // Kaydetme işlemi başarılı olduktan sonra:
        onComplete?()
    }
} 