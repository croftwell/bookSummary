import SwiftUI

struct CustomAlertView: View {
    
    let message: String
    let type: LoginViewModel.AlertType
    let dismissAction: () -> Void
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: type.iconName)
                    .foregroundColor(.white)
                
                Text(message)
                    .foregroundColor(.white)
                    .font(.footnote)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding()
            .background(type.color)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.2), radius: 5, y: 3)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .onEnded { value in
                    // Yukarı doğru kaydırma hareketini algıla
                    if value.translation.height < -10 {
                        dismissAction()
                    }
                }
        )
    }
}

// MARK: - Alert Type Uzantısı
// LoginViewModel'e bağımlılığı azaltmak için ikon bilgisini buraya taşıyabiliriz.
extension LoginViewModel.AlertType {
    var iconName: String {
        switch self {
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "xmark.circle.fill"
        }
    }
}

// MARK: - Önizleme
#Preview {
    ZStack {
        Color.gray.opacity(0.1).ignoresSafeArea()
        VStack(spacing: 20) {
            CustomAlertView(
                message: "Şifre sıfırlama e-postası gönderildi. Lütfen gelen kutunuzu kontrol edin.",
                type: .success,
                dismissAction: { print("Dismiss Success") }
            )
            
            CustomAlertView(
                message: "Bir hata oluştu. Lütfen bilgilerinizi kontrol edip tekrar deneyin.",
                type: .error,
                dismissAction: { print("Dismiss Error") }
            )
        }
    }
}
