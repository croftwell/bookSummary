import SwiftUI

struct EmailLoginView: View {
    
    @ObservedObject var viewModel: EmailLoginViewModel
    @EnvironmentObject var loginViewModel: LoginViewModel
    
    var onSignupTapped: () -> Void
    var onCloseTapped: () -> Void
    
    enum LoginField: Hashable {
        case email, password
    }
    @FocusState private var focusedLoginField: LoginField?
    
    @State private var isPasswordVisible = false
    
    var body: some View {
        VStack(spacing: 0) {
            AuthHeaderView(
                title: LocalizedStringKey("login_title"),
                actionButtonTitle: LocalizedStringKey("login_signup_button"),
                closeAction: onCloseTapped,
                mainAction: onSignupTapped
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
            focusedLoginField = nil
        }
        .onChange(of: viewModel.fieldToFocus, perform: handleFocusChange)
    }
    
    private var formContent: some View {
        VStack(alignment: .leading, spacing: 5) {
            emailField
                .padding(.bottom, 10)
            
            passwordField
            
            loginButton
                .padding(.vertical, 20)
            
            forgotPasswordLink
        }
    }
    
    private var emailField: some View {
        VStack(alignment: .leading, spacing: 5) {
            if viewModel.didAttemptLogin, let errorKey = viewModel.emailErrorMessage {
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
                onSubmitAction: { focusedLoginField = .password },
                focus: $focusedLoginField,
                fieldIdentifier: .email,
                isValid: viewModel.isEmailValid,
                didAttemptAction: viewModel.didAttemptLogin
            ) {
                TextField(String(localized: "login_email_placeholder", table: "Auth"), text: $viewModel.email)
            }
        }
    }
    
    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 5) {
            if viewModel.didAttemptLogin, let errorKey = viewModel.passwordErrorMessage {
                validationErrorText(for: errorKey)
            }
            CustomInputField(
                iconName: "lock.fill",
                text: $viewModel.password,
                isSecure: true,
                isPasswordVisible: $isPasswordVisible,
                textContentType: .password,
                submitLabel: .done,
                onSubmitAction: viewModel.login,
                focus: $focusedLoginField,
                fieldIdentifier: .password,
                isValid: viewModel.isPasswordValid,
                didAttemptAction: viewModel.didAttemptLogin
            ) {
                Group {
                    if isPasswordVisible {
                        TextField(String(localized: "login_password_placeholder", table: "Auth"), text: $viewModel.password)
                    } else {
                        SecureField(String(localized: "login_password_placeholder", table: "Auth"), text: $viewModel.password)
                    }
                }
            }
        }
    }
    
    private var loginButton: some View {
        Button(action: viewModel.login) {
            if viewModel.isLoggingIn {
                ProgressView().frame(maxWidth: .infinity)
            } else {
                Text(LocalizedStringKey("login_button"), tableName: "Auth").frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(viewModel.isLoggingIn)
    }
    
    private var forgotPasswordLink: some View {
        Button(action: loginViewModel.requestShowForgotPassword) {
            Text(LocalizedStringKey("login_forgot_password_link"), tableName: "Auth")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func validationErrorText(for key: String) -> some View {
        Text(LocalizedStringKey(key), tableName: "Auth")
            .foregroundColor(.red)
            .font(.caption)
    }
    
    private func handleFocusChange(newFocusField: LoginField?) {
        if let field = newFocusField {
            focusedLoginField = field
            viewModel.fieldToFocus = nil // Odak isteğini sıfırla
        }
    }
}

#Preview {
    let emailLoginVM = EmailLoginViewModel(onAuthenticationSuccess: nil, onErrorOccurred: nil)
    let loginVM = LoginViewModel()
    
    return EmailLoginView(
        viewModel: emailLoginVM,
        onSignupTapped: {},
        onCloseTapped: {}
    )
    .environmentObject(loginVM)
}
