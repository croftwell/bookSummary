import SwiftUI

struct SignupView: View {
    
    @ObservedObject var viewModel: SignupViewModel
    
    var onLoginTapped: () -> Void
    var onCloseTapped: () -> Void
    
    enum Field: Hashable, CaseIterable {
        case name, email, password
    }
    @FocusState private var focusedField: Field?
    
    @State private var isPasswordVisible = false
    
    var body: some View {
        VStack(spacing: 0) {
            AuthHeaderView(
                title: LocalizedStringKey("signup_title"),
                actionButtonTitle: LocalizedStringKey("login_button"),
                closeAction: onCloseTapped,
                mainAction: onLoginTapped
            )
            
            Divider()

            ScrollView {
                formContent
                    .padding()
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
        .onAppear(perform: focusOnFirstField)
        .onChange(of: viewModel.fieldToFocus, perform: handleFocusChange)
    }
    
    private var formContent: some View {
        VStack(alignment: .leading, spacing: 5) {
            // HATA DÜZELTMESİ: .padding(.bottom(10)) -> .padding(.bottom, 10)
            nameField.padding(.bottom, 10)
            emailField.padding(.bottom, 10)
            passwordField.padding(.bottom, 10)
            
            if let errorKey = viewModel.genericErrorMessage {
                validationErrorText(for: errorKey)
                    .padding(.top, 5)
            }
            
            signupButton.padding(.top, 10)
        }
    }
    
    private var nameField: some View {
        VStack(alignment: .leading, spacing: 5) {
            if viewModel.didAttemptSignup, let errorKey = viewModel.nameErrorMessage {
                validationErrorText(for: errorKey)
            }
            CustomInputField(
                iconName: "person.fill",
                text: $viewModel.name,
                isSecure: false,
                isPasswordVisible: .constant(false),
                textContentType: .name,
                submitLabel: .next,
                onSubmitAction: { focusedField = .email },
                focus: $focusedField,
                fieldIdentifier: .name,
                isValid: viewModel.isNameValid,
                didAttemptAction: viewModel.didAttemptSignup
            ) {
                TextField(String(localized: "signup_name_placeholder", table: "Auth"), text: $viewModel.name)
            }
        }
    }
    
    private var emailField: some View {
        VStack(alignment: .leading, spacing: 5) {
            if viewModel.didAttemptSignup, let errorKey = viewModel.emailErrorMessage {
                validationErrorText(for: errorKey)
            }
            CustomInputField(
                iconName: "envelope.fill",
                text: $viewModel.email,
                isSecure: false,
                isPasswordVisible: .constant(false),
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                autocapitalization: .none,
                submitLabel: .next,
                onSubmitAction: { focusedField = .password },
                focus: $focusedField,
                fieldIdentifier: .email,
                isValid: viewModel.isEmailValid,
                didAttemptAction: viewModel.didAttemptSignup
            ) {
                TextField(String(localized: "signup_email_placeholder", table: "Auth"), text: $viewModel.email)
            }
        }
    }
    
    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 5) {
            if viewModel.didAttemptSignup, let errorKey = viewModel.passwordErrorMessage {
                validationErrorText(for: errorKey)
            }
            CustomInputField(
                iconName: "lock.fill",
                text: $viewModel.password,
                isSecure: true,
                isPasswordVisible: $isPasswordVisible,
                textContentType: .newPassword,
                submitLabel: .done,
                onSubmitAction: viewModel.signUpWithEmail,
                focus: $focusedField,
                fieldIdentifier: .password,
                isValid: viewModel.isPasswordValid,
                didAttemptAction: viewModel.didAttemptSignup
            ) {
                Group {
                    if isPasswordVisible {
                        TextField(String(localized: "signup_password_placeholder", table: "Auth"), text: $viewModel.password)
                    } else {
                        SecureField(String(localized: "signup_password_placeholder", table: "Auth"), text: $viewModel.password)
                    }
                }
            }
        }
    }
    
    private var signupButton: some View {
        Button(action: viewModel.signUpWithEmail) {
            if viewModel.isLoading {
                ProgressView().frame(maxWidth: .infinity)
            } else {
                Text(LocalizedStringKey("signup_button"), tableName: "Auth").frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(viewModel.isLoading)
    }

    private func validationErrorText(for key: String) -> some View {
        Text(LocalizedStringKey(key), tableName: "Auth")
            .foregroundColor(.red)
            .font(.caption)
    }
    
    private func focusOnFirstField() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            focusedField = .name
        }
    }
    
    private func handleFocusChange(fieldToFocus: SignupViewModel.FocusableField?) {
        if let field = fieldToFocus as? Field {
            focusedField = field
            viewModel.resetFocusRequest()
        }
    }
}


// MARK: - Auth Header View

/// Kimlik doğrulama sheet'leri için ortak başlık görünümü.
struct AuthHeaderView: View {
    let title: LocalizedStringKey
    var actionButtonTitle: LocalizedStringKey? = nil
    
    let closeAction: () -> Void
    var mainAction: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Button(action: closeAction) {
                Image(systemName: "xmark")
                    .foregroundColor(.gray)
                    .font(.title3)
            }
            
            Text(title, tableName: "Auth")
                .font(.title2).bold()
                .padding(.leading, 8)
            
            Spacer()
            
            if let actionTitle = actionButtonTitle, let action = mainAction {
                Button(action: action) {
                    Text(actionTitle, tableName: "Auth")
                }
                .foregroundColor(Theme.linkedinBlue)
                .font(.body.weight(.semibold))
            }
        }
        .padding()
    }
}

// MARK: - Custom Input Field View

/// Genel amaçlı, ikonlu ve doğrulamalı metin giriş alanı.
struct CustomInputField<FieldContentType: View, FocusableFieldType: Hashable>: View {
    let iconName: String
    @Binding var text: String
    let isSecure: Bool
    @Binding var isPasswordVisible: Bool
    
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var autocapitalization: UITextAutocapitalizationType = .sentences
    var submitLabel: SubmitLabel = .next
    var onSubmitAction: (() -> Void)? = nil
    
    var focus: FocusState<FocusableFieldType?>.Binding
    var fieldIdentifier: FocusableFieldType
    
    let isValid: Bool
    let didAttemptAction: Bool
    
    @ViewBuilder let fieldContent: () -> FieldContentType
    
    private var currentBackgroundColor: Color {
        if focus.wrappedValue == fieldIdentifier {
            return Theme.focusedBackground
        } else if didAttemptAction && !isValid {
            return Theme.invalidBackground
        } else {
            return Theme.fieldBackground
        }
    }
    
    private var currentBorderColor: Color {
        if focus.wrappedValue == fieldIdentifier {
            return Theme.focusedBorder
        } else if didAttemptAction && !isValid {
            return Theme.invalidBorder
        } else {
            return .clear
        }
    }
    
    private var currentIconColor: Color {
        if focus.wrappedValue == fieldIdentifier {
            return Theme.focusedBorder
        } else if didAttemptAction && !isValid {
            return Theme.invalidBorder
        } else {
            return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: iconName)
                .foregroundColor(currentIconColor)
                .frame(width: 40, alignment: .center)
            
            fieldContent()
                .focused(focus, equals: fieldIdentifier)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .autocapitalization(autocapitalization)
                .submitLabel(submitLabel)
                .onSubmit { onSubmitAction?() }
                .frame(height: 48)
            
            rightSideButtons
        }
        .background(currentBackgroundColor)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(currentBorderColor, lineWidth: 1)
        )
        .animation(.easeOut(duration: 0.2), value: focus.wrappedValue)
        .animation(.easeOut(duration: 0.2), value: isValid)
    }
    
    private var rightSideButtons: some View {
        HStack(spacing: 10) {
            if !text.isEmpty && focus.wrappedValue == fieldIdentifier {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray.opacity(0.6))
                }
            }
            
            if isSecure {
                Button { isPasswordVisible.toggle() } label: {
                    Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.trailing, 15)
    }
}

#Preview {
    let signupVM = SignupViewModel(onAuthenticationSuccess: nil)
    return SignupView(viewModel: signupVM, onLoginTapped: {}, onCloseTapped: {})
}
