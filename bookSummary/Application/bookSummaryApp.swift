import SwiftUI
import FirebaseCore

@main
struct bookSummaryApp: App {
    
    // Uygulama durumunu yöneten enum
    private enum AppState {
        case onboarding
        case authentication
        case habitSetup
        case mainApp
    }
    
    // UserDefaults'tan kullanıcı durumlarını okumak için @AppStorage
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("hasSetHabits") private var hasSetHabits: Bool = false
    
    // Kimlik doğrulama durumu. Gerçek uygulamada bu bir AuthManager'dan gelebilir.
    @State private var isAuthenticated: Bool = false

    // Coordinator'lar
    @StateObject private var onboardingCoordinator = OnboardingCoordinator()
    @StateObject private var loginCoordinator = LoginCoordinator()
    @StateObject private var habitsCoordinator = HabitsCoordinator()

    init() {
        FirebaseApp.configure()
        // Uygulama başlarken mevcut kullanıcı durumunu kontrol etmek daha doğru olacaktır.
        // Bu, bir AuthManager servisi tarafından yönetilebilir.
        // isAuthenticated = Auth.auth().currentUser != nil
    }

    // Mevcut duruma göre hangi Coordinator'ın başlatılacağını belirler
    private var currentState: AppState {
        if !hasCompletedOnboarding {
            return .onboarding
        } else if !isAuthenticated {
            return .authentication
        } else if !hasSetHabits {
            return .habitSetup
        } else {
            return .mainApp
        }
    }

    var body: some Scene {
        WindowGroup {
            rootView
        }
    }
    
    // Mevcut duruma göre uygun görünümü veya coordinator'ı döndüren ana görünüm
    @ViewBuilder
    private var rootView: some View {
        switch currentState {
        case .onboarding:
            onboardingCoordinator.start()
                .onAppear {
                    onboardingCoordinator.didFinishOnboarding = {
                        hasCompletedOnboarding = true
                    }
                }
        case .authentication:
            loginCoordinator.start()
                .onAppear {
                    loginCoordinator.didFinishAuth = {
                        isAuthenticated = true
                    }
                }
        case .habitSetup:
            habitsCoordinator.start()
                .onAppear {
                    habitsCoordinator.didFinishHabits = {
                        hasSetHabits = true
                    }
                }
        case .mainApp:
            // Onboarding, giriş ve alışkanlık ayarları tamamlandıysa ana içerik gösterilir.
            ContentView()
        }
    }
}
