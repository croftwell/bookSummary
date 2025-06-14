import SwiftUI
import FirebaseCore

@main
struct bookSummaryApp: App {
    
    private enum AppState {
        case onboarding
        case authentication
        case habitSetup
        case mainApp
    }
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("hasSetHabits") private var hasSetHabits: Bool = false
    
    @State private var isAuthenticated: Bool = false
    
    // --- TEST İÇİN YENİ STATE ---
    // Uygulamanın test modunda olup olmadığını belirler.
    // `true` ise onboarding her zaman gösterilir.
    @State private var isInTestMode: Bool = true

    @StateObject private var onboardingCoordinator = OnboardingCoordinator()
    @StateObject private var loginCoordinator = LoginCoordinator()
    @StateObject private var habitsCoordinator = HabitsCoordinator()

    init() {
        FirebaseApp.configure()
        // isAuthenticated = Auth.auth().currentUser != nil
    }

    private var currentState: AppState {
        // --- DEĞİŞİKLİK BURADA ---
        // Test modunu ve normal akışı kontrol eden mantık.
        // Eğer test modundaysak ve onboarding bitmediyse, onboarding gösterilir.
        if isInTestMode && !hasCompletedOnboarding {
            return .onboarding
        }
        
        // Normal akış mantığı
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
                .onAppear(perform: setupForTesting)
        }
    }
    
    @ViewBuilder
    private var rootView: some View {
        switch currentState {
        case .onboarding:
            onboardingCoordinator.start()
                .onAppear {
                    onboardingCoordinator.didFinishOnboarding = {
                        // Onboarding bittiğinde durumunu kaydet.
                        // Bu, `currentState`'in bir sonraki aşamaya geçmesini tetikleyecektir.
                        self.hasCompletedOnboarding = true
                    }
                }
        case .authentication:
            loginCoordinator.start()
                .onAppear {
                    loginCoordinator.didFinishAuth = {
                        self.isAuthenticated = true
                    }
                }
        case .habitSetup:
            habitsCoordinator.start()
                .onAppear {
                    habitsCoordinator.didFinishHabits = {
                        self.hasSetHabits = true
                    }
                }
        case .mainApp:
            ContentView()
        }
    }
    
    /// Sadece test amacıyla, uygulama her açıldığında onboarding durumunu sıfırlar.
    private func setupForTesting() {
        if isInTestMode {
            // Test modunda, uygulama her başladığında onboarding'in
            // tamamlanmadığını varsayarak durumu sıfırlıyoruz.
            hasCompletedOnboarding = false
        }
    }
}
