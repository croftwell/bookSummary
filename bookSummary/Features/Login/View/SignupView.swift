import SwiftUI

struct SignupView: View {
    
    // ViewModel dışarıdan inject edilecek
    @ObservedObject var viewModel: SignupViewModel
    
    // Login butonuna tıklandığında çağrılacak closure
    var onLoginTapped: (() -> Void)?
    // Kapatma butonuna tıklandığında çağrılacak closure
    var onCloseTapped: (() -> Void)?
    
    // Odaklanma Yönetimi
    enum Field: Hashable {
        case name, email, password
    }
    @FocusState private var focusedField: Field?

    // Şifre Görünürlüğü
    @State private var isPasswordVisible = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Özel Başlık Alanı - X Butonu, Başlık ve Giriş Yap Butonu
            HStack { 
                // Kapatma Butonu (X)
                Button { 
                    onCloseTapped?()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .font(.title3)
                }
                
                Text(LocalizedStringKey("signup_title"), tableName: "Auth")
                    .font(.title2).bold()
                    .padding(.leading, 8) // X butonu ile arasına küçük bir boşluk
                
                Spacer() // Giriş Yap butonunu sağa iter
                
                Button(action: { 
                    onLoginTapped?() 
                }) { 
                    Text(LocalizedStringKey("signup_login_button"), tableName: "Auth") 
                }
                    .foregroundColor(Theme.linkedinBlue)
                    .font(.body.weight(.semibold))
            }
            .padding()
            
            Divider()

            // ScrollView eklendi
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    
                    // Ad Alanı
                    if viewModel.didAttemptSignup, let errorKey = viewModel.nameErrorMessage {
                        Text(LocalizedStringKey(errorKey), tableName: "Auth").foregroundColor(.red).font(.caption)
                    }
                    CustomInputField(
                        iconName: "person.fill",
                        placeholder: String(localized: "signup_name_placeholder", table: "Auth"),
                        text: $viewModel.name,
                        isSecure: false,
                        isPasswordVisible: .constant(false),
                        textContentType: .name,
                        submitLabel: .next,
                        onSubmitAction: { 
                            // Odak değişikliğini asenkron yap
                            DispatchQueue.main.async { focusedField = .email } 
                        },
                        focus: $focusedField,
                        fieldIdentifier: .name,
                        isValid: viewModel.isNameValid,
                        didAttemptSignup: viewModel.didAttemptSignup
                    ) { 
                        TextField(String(localized: "signup_name_placeholder", table: "Auth"), text: $viewModel.name)
                    }
                    .padding(.bottom, 10)
                    
                    // E-posta Alanı
                    if viewModel.didAttemptSignup, let errorKey = viewModel.emailErrorMessage {
                        Text(LocalizedStringKey(errorKey), tableName: "Auth").foregroundColor(.red).font(.caption)
                    }
                    CustomInputField(
                        iconName: "envelope.fill",
                        placeholder: String(localized: "signup_email_placeholder", table: "Auth"),
                        text: $viewModel.email,
                        isSecure: false,
                        isPasswordVisible: .constant(false),
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress,
                        autocapitalization: .none,
                        submitLabel: .next,
                        onSubmitAction: { 
                            // Odak değişikliğini asenkron yap
                            DispatchQueue.main.async { focusedField = .password }
                        },
                        focus: $focusedField,
                        fieldIdentifier: .email,
                        isValid: viewModel.isEmailValid,
                        didAttemptSignup: viewModel.didAttemptSignup
                    ) { 
                        TextField(String(localized: "signup_email_placeholder", table: "Auth"), text: $viewModel.email)
                    }
                    .padding(.bottom, 10)
                    
                    // Şifre Alanı (Görünürlüğe göre TextField veya SecureField)
                    if viewModel.didAttemptSignup, let errorKey = viewModel.passwordErrorMessage {
                        Text(LocalizedStringKey(errorKey), tableName: "Auth").foregroundColor(.red).font(.caption)
                    }
                    CustomInputField(
                        iconName: "lock.fill",
                        placeholder: String(localized: "signup_password_placeholder", table: "Auth"),
                        text: $viewModel.password,
                        isSecure: true,
                        isPasswordVisible: $isPasswordVisible,
                        textContentType: .newPassword,
                        submitLabel: .done,
                        onSubmitAction: { viewModel.signUpWithEmail() },
                        focus: $focusedField,
                        fieldIdentifier: .password,
                        isValid: viewModel.isPasswordValid,
                        didAttemptSignup: viewModel.didAttemptSignup
                    ) { 
                        Group {
                            if isPasswordVisible {
                                TextField(String(localized: "signup_password_placeholder", table: "Auth"), text: $viewModel.password)
                            } else {
                                SecureField(String(localized: "signup_password_placeholder", table: "Auth"), text: $viewModel.password)
                            }
                        }
                    }
                    .padding(.bottom, 10)
                    
                    // Genel Hata Mesajı
                    if let errorKeyOrMessage = viewModel.genericErrorMessage {
                        Text(LocalizedStringKey(errorKeyOrMessage), tableName: "Auth")
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 5)
                    }
                    
                    // Kaydol Butonu (Inputların hemen altında)
                    Button(action: { 
                        viewModel.signUpWithEmail() 
                    }) {
                        if viewModel.isLoading {
                            ProgressView().frame(maxWidth: .infinity)
                        } else {
                            Text(LocalizedStringKey("signup_button"), tableName: "Auth").frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(viewModel.isLoading)
                    .padding(.top, 10) 

                }
                .padding() // Form içeriği için padding
            } // ScrollView sonu
            .onAppear {
                // View göründüğünde ilk alana odaklan (küçük gecikmeyle)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    focusedField = .name
                }
            }
            // ViewModel'den gelen odaklanma isteğini dinle
            .onChange(of: viewModel.fieldToFocus) { fieldToFocus in
                if let field = fieldToFocus as? Field { // AnyHashable'ı Field'a çevir
                    print("Odaklanma isteği algılandı: \(field)") // Debug
                    focusedField = field
                    // viewModel.resetFocusRequest() // İsteği sıfırla - GEÇİCİ OLARAK DEVRE DIŞI
                }
            }
        }
        .contentShape(Rectangle()) 
        .onTapGesture {
            focusedField = nil 
        }
        // Klavye açıldığında görünümün yeniden boyutlanmasını engelle
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    // Preview için geçici bir LoginViewModel oluşturup SignupViewModel'e geçirelim
    // let loginVM = LoginViewModel()
    // let signupVM = SignupViewModel(loginViewModel: loginVM) // Eski init
    let signupVM = SignupViewModel(onAuthenticationSuccess: nil) // Yeni init
    return SignupView(viewModel: signupVM, onLoginTapped: {}, onCloseTapped: {}) 
}

// MARK: - Custom Input Field View

// Generic hale getirildi (FocusableFieldType eklendi)
struct CustomInputField<FieldContentType: View, FocusableFieldType: Hashable>: View {
    let iconName: String
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    @Binding var isPasswordVisible: Bool
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var autocapitalization: UITextAutocapitalizationType = .sentences
    
    // Yeni property'ler
    var submitLabel: SubmitLabel = .next // Varsayılanı .next
    var onSubmitAction: (() -> Void)? = nil // Submit tuşuna basılınca çalışacak action
    
    // Odaklanma durumu (Generic tipler kullanıldı)
    var focus: FocusState<FocusableFieldType?>.Binding
    var fieldIdentifier: FocusableFieldType
    
    let isValid: Bool
    let didAttemptSignup: Bool
    
    @ViewBuilder let fieldContent: () -> FieldContentType

    // Dinamik renkler
    private var currentBackgroundColor: Color {
        if focus.wrappedValue == fieldIdentifier {
            return Theme.focusedBackground
        // Sadece deneme yapıldıysa VE geçersizse kırmızı yap
        } else if didAttemptSignup && !isValid {
            return Theme.invalidBackground
        } else {
            return Theme.fieldBackground
        }
    }
    
    private var currentBorderColor: Color {
        if focus.wrappedValue == fieldIdentifier {
            return Theme.focusedBorder
        // Sadece deneme yapıldıysa VE geçersizse kırmızı yap
        } else if didAttemptSignup && !isValid {
            return Theme.invalidBorder
        } else {
            return .clear
        }
    }
    
    // Dinamik ikon rengi
    private var currentIconColor: Color {
        if focus.wrappedValue == fieldIdentifier {
            return Theme.focusedBorder // Odaklanınca mavi (kenarlık rengiyle aynı)
        } else if didAttemptSignup && !isValid {
            return Theme.invalidBorder // Geçersiz deneme sonrası kırmızı
        } else {
            return .gray // Normal durumda gri
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            // İkon (Dinamik renk uygulandı)
            Image(systemName: iconName)
                .foregroundColor(currentIconColor)
                .frame(width: 40, alignment: .center)

            // Metin Alanı (TextField veya SecureField)
            fieldContent()
                .focused(focus, equals: fieldIdentifier)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .autocapitalization(autocapitalization)
                .submitLabel(submitLabel)
                .onSubmit {
                    onSubmitAction?()
                }
                .frame(height: 48)

            // Sağdaki Butonlar (Renkler griye sabitlendi)
            HStack(spacing: 10) {
                // Temizleme Butonu (X)
                if !text.isEmpty && focus.wrappedValue == fieldIdentifier {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray) // Renk griye sabitlendi
                    }
                }
                
                // Şifre Görünürlük Butonu (Göz)
                if isSecure {
                    Button {
                        isPasswordVisible.toggle()
                    } label: {
                        // İkon mantığı tersine çevrildi: Durumu göster
                        Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill") 
                            .foregroundColor(.gray) // Renk griye sabitlendi
                    }
                }
            }
            .padding(.trailing, 15)
        }
        .background(currentBackgroundColor)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(currentBorderColor, lineWidth: 1)
        )
    }
} 