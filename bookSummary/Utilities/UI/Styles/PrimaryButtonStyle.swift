import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // iOS 16 öncesi uyumluluk için .font ile ağırlık belirt
            .font(.headline.bold()) // .headline stilini bold yapar
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .background(Theme.linkedinBlue) // Ana buton rengi (Theme'in import edildiğini varsayar)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
} 