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

            // ScrollView kaldırıldı
            // ScrollView {
            VStack(alignment: .leading, spacing: 5) { // Eski spacing değeri buraya taşındı
                // Spacer() // Üstteki spacer kaldırıldı
                
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
                    onSubmitAction: { focusedLoginField = .password },
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
                .padding(.bottom, 10)
                
                // Genel Hata Mesajı (varsa)
                if let errorMessage = viewModel.errorMessage {
                    Text(LocalizedStringKey(errorMessage), tableName: "Auth") // Lokalize anahtar olarak kullan
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.top, 5)
                }
                
                // Giriş Yap Butonu
                Button(action: { 
                    viewModel.login() // ViewModel'deki login fonksiyonunu çağır
                }) {
                    if viewModel.isLoggingIn {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text(LocalizedStringKey("login_button"), tableName: "Auth").frame(maxWidth: .infinity) // Lokalize edildi
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, 20) // Biraz daha boşluk
                .disabled(viewModel.isLoggingIn)
                
                Spacer() // İçeriği yukarı it
            }
            .padding() // ScrollView içeriği için padding (Bu padding kalıyor)
            // ScrollView kapatma parantezi kaldırıldı
            // }
        }
        // .padding() // En dış VStack padding'i kaldırıldı, içerideki paddingler yeterli
        // NavigationTitle, DisplayMode ve Toolbar kaldırıldı
        .contentShape(Rectangle())
        .onTapGesture {
            focusedLoginField = nil // Odak kaybetme
        }
        // Klavye açıldığında görünümün yeniden boyutlanmasını engelle
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onChange(of: viewModel.fieldToFocus) { newFocusField in
            if let field = newFocusField {
                focusedLoginField = field
                // viewModel.resetFocusRequest() // Gerekirse odak isteğini sıfırlama eklenebilir
            }
        }
    }
}

#Preview { 
    // Preview için geçici bir LoginViewModel oluşturup EmailLoginViewModel'e geçirelim
    // let loginVM = LoginViewModel() // Artık doğrudan LoginViewModel'e gerek yok
    // let emailLoginVM = EmailLoginViewModel(loginViewModel: loginVM) // Eski init
    let emailLoginVM = EmailLoginViewModel(onAuthenticationSuccess: nil) // Yeni init (Preview'da başarı action'ı nil olabilir)
    return EmailLoginView(viewModel: emailLoginVM, onSignupTapped: {}, onCloseTapped: {}) 
} 