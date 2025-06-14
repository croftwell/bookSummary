import SwiftUI

struct LoginView: View {
    
    @StateObject var viewModel: LoginViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                headerText
                
                SocialLoginButton(provider: .apple) { /* TODO: viewModel.appleLogin() */ }
                SocialLoginButton(provider: .google) { /* TODO: viewModel.googleLogin() */ }
                
                divider
                
                emailContinueButton
                
                Spacer()
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $viewModel.isSheetPresented) {
            AuthenticationSheetView(loginViewModel: viewModel)
                .environmentObject(viewModel)
        }
    }
    
    private var headerText: some View {
        Text("Giriş Yap veya Kaydol")
            .font(.largeTitle).bold()
            .multilineTextAlignment(.center)
            .padding(.bottom, 30)
    }
    
    private var divider: some View {
        HStack {
            VStack { Divider() }
            Text("veya").foregroundColor(.secondary)
            VStack { Divider() }
        }
        .padding(.vertical)
    }
    
    private var emailContinueButton: some View {
        Button("E-posta ile Devam Et") {
            viewModel.requestShowSignup()
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}

// MARK: - Social Login Button

enum SocialProvider {
    case apple, google
    
    var title: String {
        switch self {
        case .apple: return "Apple ile Devam Et"
        case .google: return "Google ile Devam Et"
        }
    }
    
    var iconName: String {
        switch self {
        case .apple: return "applelogo"
        case .google: return "g.circle.fill" // Örnek ikon
        }
    }
}

struct SocialLoginButton: View {
    let provider: SocialProvider
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: provider.iconName)
                Text(provider.title)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray5))
            .foregroundColor(.primary)
            .cornerRadius(10)
        }
    }
}

#Preview {
    LoginView(viewModel: LoginViewModel())
}
