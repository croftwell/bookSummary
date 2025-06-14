import SwiftUI

struct HabitsView: View {
    
    @ObservedObject var viewModel: HabitsViewModel
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                headerView
                
                ScrollView {
                    habitsGrid
                }
                
                Spacer()
                
                completeButton
            }
            .padding()
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading) {
            Text("İlgilendiğiniz Alanlar")
                .font(.largeTitle).bold()
                .padding(.bottom, 8)
            
            Text("Size özel öneriler sunabilmemiz için birkaç alan seçin.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 30)
        }
    }
    
    private var habitsGrid: some View {
        // Derleyiciye yardımcı olmak için viewModel'den gelen verileri yerel bir sabite atıyoruz.
        let allHabits = viewModel.allHabits
        let selectedHabits = viewModel.selectedHabits
        
        return FlexibleGridView(data: allHabits, spacing: 12, alignment: .leading) { habit in
            Button(action: {
                viewModel.toggleSelection(for: habit)
            }) {
                Text(habit)
                    .font(.callout)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(selectedHabits.contains(habit) ? Theme.linkedinBlue : Color(.systemGray5))
                    .foregroundColor(selectedHabits.contains(habit) ? .white : .primary)
                    .cornerRadius(20)
            }
        }
    }
    
    private var completeButton: some View {
        // Butonun durumunu yerel bir sabite atıyoruz.
        let isDisabled = viewModel.selectedHabits.isEmpty
        
        return Button("Tamamla") {
            viewModel.saveHabits()
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(isDisabled)
    }
}

#Preview {
    HabitsView(viewModel: HabitsViewModel())
}
