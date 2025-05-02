import SwiftUI

struct ForgotPasswordView: View {
    
    @ObservedObject var viewModel: ForgotPasswordViewModel
    // Kapatma butonu için (ViewModel'deki dismiss'i çağıracak)
    var onCloseTapped: (() -> Void)?

    // Odaklanma Yönetimi
    enum Field: Hashable { 
        case email
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack(spacing: 0) { 
            // Başlık Alanı - X Butonu ve Başlık
            HStack { 
                Button { 
                    onCloseTapped?() 
                } label: { 
                    Image(systemName: "xmark").foregroundColor(.gray).font(.title3) 
                }
                Text(LocalizedStringKey("forgot_password_title"), tableName: "Auth")
                    .font(.title2).bold()
                    .padding(.leading, 8)
                Spacer() // Başlığı sola yaslamak için
            }
            .padding()
            
            Divider()

            // Form İçeriği
            VStack(alignment: .leading, spacing: 5) { 
                
                // Açıklama Metni
                Text(LocalizedStringKey("forgot_password_description"), tableName: "Auth")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
                
                // E-posta Alanı
                if viewModel.didAttemptSend, let errorKey = viewModel.emailErrorMessage {
                    Text(LocalizedStringKey(errorKey), tableName: "Auth").foregroundColor(.red).font(.caption)
                }
                CustomInputField(
                    iconName: "envelope.fill",
                    placeholder: String(localized: "forgot_password_email_placeholder", table: "Auth"),
                    text: $viewModel.email,
                    isSecure: false,
                    isPasswordVisible: .constant(false),
                    keyboardType: .emailAddress,
                    textContentType: .emailAddress,
                    autocapitalization: .none,
                    submitLabel: .done, // Tek alan olduğu için .done
                    onSubmitAction: { viewModel.sendPasswordResetEmail() }, // Direkt gönder
                    focus: $focusedField,
                    fieldIdentifier: .email,
                    isValid: viewModel.isEmailValid,
                    didAttemptSignup: viewModel.didAttemptSend // didAttemptSignup yerine didAttemptSend kullandık
                ) { 
                    TextField(String(localized: "forgot_password_email_placeholder", table: "Auth"), text: $viewModel.email)
                }
                .padding(.bottom, 10)
                
                // Genel Hata / Başarı Mesajı
                if let errorMessage = viewModel.errorMessage {
                    Text(LocalizedStringKey(errorMessage), tableName: "Auth")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.top, 5)
                } else if let successMessage = viewModel.successMessage {
                    Text(LocalizedStringKey(successMessage), tableName: "Auth")
                        .foregroundColor(.green) // Başarıyı yeşil gösterelim
                        .font(.caption)
                        .padding(.top, 5)
                }
                
                // Gönder Butonu
                Button(action: { 
                    viewModel.sendPasswordResetEmail()
                }) {
                    if viewModel.isSending {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text(LocalizedStringKey("forgot_password_button"), tableName: "Auth")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, 20)
                .disabled(viewModel.isSending || viewModel.successMessage != nil) // Gönderiliyorsa veya başarılı olduysa devredışı bırak
                
                Spacer() // İçeriği yukarı it
            }
            .padding() 
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil // Odak kaybetme
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onChange(of: viewModel.fieldToFocus) { newFocusField in
            focusedField = newFocusField // ViewModel'den gelen odak isteğini uygula
        }
        // View göründüğünde email alanına odaklan (opsiyonel)
        // .onAppear { focusedField = .email }
    }
}

#Preview { 
    let forgotPasswordVM = ForgotPasswordViewModel(onCompletion: { _ in })
    return ForgotPasswordView(viewModel: forgotPasswordVM, onCloseTapped: {}) 
} 