import SwiftUI

struct ForgotPasswordView: View {
    
    @ObservedObject var viewModel: ForgotPasswordViewModel
    var onCloseTapped: () -> Void
    
    enum Field: Hashable {
        case email
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack(spacing: 0) {
            AuthHeaderView(
                title: LocalizedStringKey("forgot_password_title"),
                closeAction: onCloseTapped
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
        .onChange(of: viewModel.fieldToFocus, perform: handleFocusChange)
    }
    
    private var formContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            descriptionText
            emailField
            sendButton
            Spacer()
        }
    }
    
    private var descriptionText: some View {
        Text(LocalizedStringKey("forgot_password_description"), tableName: "Auth")
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
    
    private var emailField: some View {
        VStack(alignment: .leading, spacing: 5) {
            if viewModel.didAttemptSend, let errorKey = viewModel.emailErrorMessage {
                validationErrorText(for: errorKey)
            } else if let genericErrorKey = viewModel.errorMessage {
                // Sunucudan gelen genel hatalar için
                validationErrorText(for: genericErrorKey)
            }
            
            CustomInputField(
                iconName: "envelope.fill",
                text: $viewModel.email,
                isSecure: false,
                isPasswordVisible: .constant(false),
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                autocapitalization: .none,
                submitLabel: .done,
                onSubmitAction: viewModel.sendPasswordResetEmail,
                focus: $focusedField,
                fieldIdentifier: .email,
                isValid: viewModel.isEmailValid,
                didAttemptAction: viewModel.didAttemptSend
            ) {
                TextField(String(localized: "forgot_password_email_placeholder", table: "Auth"), text: $viewModel.email)
            }
        }
    }
    
    private var sendButton: some View {
        Button(action: viewModel.sendPasswordResetEmail) {
            if viewModel.isSending {
                ProgressView().frame(maxWidth: .infinity)
            } else {
                Text(LocalizedStringKey("forgot_password_button"), tableName: "Auth").frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(viewModel.isSending || viewModel.isSuccess)
    }
    
    private func validationErrorText(for key: String) -> some View {
        Text(LocalizedStringKey(key), tableName: "Auth")
            .foregroundColor(.red)
            .font(.caption)
    }
    
    private func handleFocusChange(newFocusField: Field?) {
        if let field = newFocusField {
            focusedField = field
            viewModel.fieldToFocus = nil
        }
    }
}

#Preview {
    let vm = ForgotPasswordViewModel(onCompletion: { _ in })
    // vm.errorMessage = "error_user_not_found"
    // vm.didAttemptSend = true
    return ForgotPasswordView(viewModel: vm, onCloseTapped: {})
}
