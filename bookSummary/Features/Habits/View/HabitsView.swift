import SwiftUI

struct HabitsView: View {
    
    @ObservedObject var viewModel: HabitsViewModel
    
    // Örnek alışkanlıklar (daha sonra ViewModel'den gelebilir)
    let allHabits = ["Okuma", "Spor", "Meditasyon", "Yazma", "Müzik", "Kodlama"]
    @State private var selectedHabits: Set<String> = []
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("İlgilendiğiniz Alanlar Neler?")
                    .font(.largeTitle).bold()
                    .padding(.bottom)
                
                Text("Size özel öneriler sunabilmemiz için birkaç alan seçin.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 30)
                
                // Alışkanlık Seçim Alanı (Grid veya List kullanılabilir)
                ScrollView {
                    FlexibleGridView(data: allHabits, spacing: 10, alignment: .leading) { habit in
                        Button(action: { toggleSelection(for: habit) }) {
                            Text(habit)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(selectedHabits.contains(habit) ? Theme.linkedinBlue : Color(UIColor.systemGray5))
                                .foregroundColor(selectedHabits.contains(habit) ? .white : .primary)
                                .cornerRadius(15)
                        }
                    }
                }
                
                Spacer()
                
                // Tamamla Butonu
                Button("Tamamla") {
                    // Seçilenleri ViewModel'e aktar ve kaydet
                    // viewModel.selectedHabits = selectedHabits // Eğer ViewModel'de tutulacaksa
                    viewModel.saveHabits()
                }
                .buttonStyle(PrimaryButtonStyle()) // LoginView'dan alınan stil
                .disabled(selectedHabits.isEmpty) // Seçim yapılmadıysa pasif
                
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
    
    private func toggleSelection(for habit: String) {
        if selectedHabits.contains(habit) {
            selectedHabits.remove(habit)
        } else {
            selectedHabits.insert(habit)
        }
    }
}

// Esnek Grid Layout ve yardımcıları merkezi dosyaya taşındı.

#Preview {
    HabitsView(viewModel: HabitsViewModel())
} 