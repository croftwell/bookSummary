import SwiftUI

struct CustomAlertView: View {
    
    let message: String
    let type: LoginViewModel.AlertType // LoginViewModel'deki enum'u kullanıyoruz
    let dismissAction: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                // Opsiyonel: İkon eklenebilir
                // Image(systemName: type == .success ? "checkmark.circle.fill" : "xmark.circle.fill")
                //     .foregroundColor(.white)
                
                Text(message)
                    .foregroundColor(.white)
                    .font(.footnote)
                    .lineLimit(nil) // Çok satırlı metinler için
                    .multilineTextAlignment(.leading)
                
                Spacer() // Metni sola yasla
                
                // Opsiyonel: Kapatma butonu (X)
                // Button { dismissAction() } label: {
                //     Image(systemName: "xmark")
                //         .foregroundColor(.white.opacity(0.7))
                // }
            }
            .padding()
            .background(type.color) // ViewModel'deki renge göre arkaplan
            .cornerRadius(10)
            .shadow(radius: 5)
            
            Spacer() // Alert'i yukarı it
        }
        .padding(.horizontal) // Kenarlardan boşluk
        .padding(.top, 8) // Üst kenardan boşluk
        // Swipe Up Hareketi
        .gesture(
            DragGesture(minimumDistance: 50, coordinateSpace: .local)
                .onEnded { value in
                    if value.translation.height < -20 { // Yukarı doğru yeterli kaydırma
                        dismissAction()
                    }
                }
        )
    }
}

#Preview {
    // Preview için örnekler
    VStack {
        CustomAlertView(message: "Şifre sıfırlama e-postası gönderildi. Lütfen gelen kutunuzu kontrol edin.", type: .success, dismissAction: { print("Dismiss Success") })
        
        CustomAlertView(message: "Bir hata oluştu. Lütfen tekrar deneyin.", type: .error, dismissAction: { print("Dismiss Error") })
    }
} 