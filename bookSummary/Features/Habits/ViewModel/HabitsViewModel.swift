import Foundation
import Combine

class HabitsViewModel: ObservableObject {
    
    /// Kullanıcının seçebileceği tüm alışkanlıkların listesi.
    let allHabits = ["Okuma", "Spor", "Meditasyon", "Yazma", "Müzik", "Kodlama", "Tarih", "Bilim Kurgu", "Kişisel Gelişim"]
    
    /// Kullanıcının seçtiği alışkanlıkları tutar. View bu değişkeni dinler.
    @Published var selectedHabits: Set<String> = []
    
    /// Akış tamamlandığında Coordinator'ı bilgilendirmek için kullanılır.
    var onComplete: (() -> Void)?
    
    /// Kullanıcının bir alışkanlık seçimi yaptığında veya seçimini kaldırdığında çağrılır.
    /// - Parameter habit: Seçilen veya seçimi kaldırılan alışkanlık.
    func toggleSelection(for habit: String) {
        if selectedHabits.contains(habit) {
            selectedHabits.remove(habit)
        } else {
            selectedHabits.insert(habit)
        }
    }
    
    /// Seçilen alışkanlıkları kaydetme işlemini başlatır.
    func saveHabits() {
        // TODO: Seçilen alışkanlıkları (self.selectedHabits) Firebase'e veya UserDefaults'a kaydetme mantığı.
        print("Alışkanlıklar kaydedildi (simülasyon): \(selectedHabits)")
        
        // Kaydetme işlemi başarılı olduktan sonra Coordinator'ı bilgilendir.
        onComplete?()
    }
}
