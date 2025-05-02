import SwiftUI

struct EmailLoginView: View {
    
    // ViewModel dışarıdan inject edilecek
    @ObservedObject var viewModel: EmailLoginViewModel
    
    // Signup moduna geçmek için action
    var onSignupTapped: (() -> Void)?
    // Kapatma butonuna tıklandığında çağrılacak closure
    var onCloseTapped: (() -> Void)? // Yeni parametre
    
    // Environment dismiss kaldırıldı
    // @Environment(\.dismiss) var dismiss
    
    // Odaklanma Yönetimi
    enum LoginField: Hashable { 
        case email, password
    }
    @FocusState private var focusedLoginField: LoginField?
    
    // Şifre Görünürlüğü
    @State private var isPasswordVisible = false
    
    // LoginViewModel'e erişim (Şifremi Unuttum'u tetiklemek için)
    // Not: Bu ideal değil, Coordinator daha iyi olurdu. Ama mevcut yapıda gerekli.
    @EnvironmentObject var loginViewModel: LoginViewModel 
    
    var body: some View {
        // NavigationView kaldırıldı
        VStack(spacing: 0) { // Spacing 0 yapıldı, padding ile ayarlanacak
            
            // Özel Başlık Alanı - X Butonu, Başlık ve Kaydol Butonu
            HStack { 
                // Kapatma Butonu (X)
                Button { 
                    onCloseTapped?()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .font(.title3)
                }
                
                // Spacer kaldırıldı, başlık sola yaslandı
                // Spacer() // Başlığı biraz sağa iter
                
                Text(LocalizedStringKey("login_title"), tableName: "Auth") // Lokalize edildi
                    .font(.title2).bold()
                    .padding(.leading, 8) // X butonu ile arasına küçük bir boşluk
                
                Spacer() // Kaydol butonunu sağa iter (Bu Spacer kalıyor)
                
                Button(action: { // Buton içeriği localize edildi
                    onSignupTapped?() 
                }) { // Label kısmı
                    Text(LocalizedStringKey("login_signup_button"), tableName: "Auth")
                }
                .foregroundColor(Theme.linkedinBlue)
                .font(.body.weight(.semibold))
            }
            .padding() // Başlık için padding
            
            Divider() // Başlık ve form arasına çizgi

            // ScrollView eklendi
            ScrollView {
                VStack(alignment: .leading, spacing: 5) { 
                    // Büyük başlık metni kaldırıldı
                    // Text("E-posta ile Giriş Yap") ...
                    
                    // E-posta Alanı
                    if viewModel.didAttemptLogin, let errorKey = viewModel.emailErrorMessage {
                        Text(LocalizedStringKey(errorKey), tableName: "Auth").foregroundColor(.red).font(.caption)
                    }
                    CustomInputField(
                        iconName: "envelope.fill",
                        placeholder: String(localized: "login_email_placeholder", table: "Auth"),
                        text: $viewModel.email,
                        isSecure: false,
                        isPasswordVisible: .constant(false),
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress,
                        autocapitalization: .none,
                        submitLabel: .next, 
                        onSubmitAction: { 
                            // Odak değişikliğini asenkron yap
                            DispatchQueue.main.async { focusedLoginField = .password } 
                        },
                        focus: $focusedLoginField,
                        fieldIdentifier: .email,
                        isValid: viewModel.isEmailValid,
                        didAttemptSignup: viewModel.didAttemptLogin
                    ) { 
                        TextField(String(localized: "login_email_placeholder", table: "Auth"), text: $viewModel.email)
                    }
                    .padding(.bottom, 10)
                    
                    // Şifre Alanı
                    if viewModel.didAttemptLogin, let errorKey = viewModel.passwordErrorMessage {
                        Text(LocalizedStringKey(errorKey), tableName: "Auth").foregroundColor(.red).font(.caption)
                    }
                    CustomInputField(
                        iconName: "lock.fill",
                        placeholder: String(localized: "login_password_placeholder", table: "Auth"),
                        text: $viewModel.password,
                        isSecure: true,
                        isPasswordVisible: $isPasswordVisible,
                        textContentType: .password,
                        submitLabel: .done, 
                        onSubmitAction: { viewModel.login() },
                        focus: $focusedLoginField,
                        fieldIdentifier: .password,
                        isValid: viewModel.isPasswordValid,
                        didAttemptSignup: viewModel.didAttemptLogin
                    ) { 
                        Group { // TextField/SecureField seçimi
                            if isPasswordVisible {
                                TextField(String(localized: "login_password_placeholder", table: "Auth"), text: $viewModel.password)
                            } else {
                                SecureField(String(localized: "login_password_placeholder", table: "Auth"), text: $viewModel.password)
                            }
                        }
                    }
                    
                    // Genel Hata Mesajı (varsa)
                    if let errorMessage = viewModel.errorMessage {
                        Text(LocalizedStringKey(errorMessage), tableName: "Auth") 
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 5)
                    }
                    
                    // Giriş Yap Butonu
                    Button(action: { 
                        viewModel.login()
                    }) {
                        if viewModel.isLoggingIn {
                            ProgressView().frame(maxWidth: .infinity)
                        } else {
                            Text(LocalizedStringKey("login_button"), tableName: "Auth").frame(maxWidth: .infinity) 
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.vertical, 20) 
                    .disabled(viewModel.isLoggingIn)
                    
                    // Yeni Ortalanmış Şifremi Unuttum Butonu
                    Button(action: { 
                        loginViewModel.requestShowForgotPassword()
                    }) {
                        Text(LocalizedStringKey("login_forgot_password_link"), tableName: "Auth")
                            .font(.footnote)
                            .foregroundColor(.secondary) 
                    }
                    .frame(maxWidth: .infinity) 
                    .padding(.bottom, 10)
                }
                .padding() 
            } // ScrollView sonu
            // ScrollView'a ignoreSafeArea eklendi
            .ignoresSafeArea(.keyboard, edges: .bottom)
            // .padding() // ScrollView dışındaki padding kaldırıldı
        }
        // .padding() // En dış VStack padding'i kaldırıldı, içerideki paddingler yeterli
        // NavigationTitle, DisplayMode ve Toolbar kaldırıldı
        .contentShape(Rectangle())
        .onTapGesture {
            focusedLoginField = nil // Odak kaybetme
        }
        .onChange(of: viewModel.fieldToFocus) { newFocusField in
            if let field = newFocusField {
                focusedLoginField = field
                // viewModel.resetFocusRequest() // Gerekirse odak isteğini sıfırlama eklenebilir
            }
        }
    }
}

#Preview { 
    let emailLoginVM = EmailLoginViewModel(onAuthenticationSuccess: nil)
    // Preview için LoginViewModel'i EnvironmentObject olarak eklememiz gerekir
    let loginVM = LoginViewModel() 
    return EmailLoginView(viewModel: emailLoginVM, onSignupTapped: {}, onCloseTapped: {})
        .environmentObject(loginVM) // Inject LoginViewModel for preview
} 