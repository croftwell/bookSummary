//
//  bookSummaryApp.swift
//  bookSummary
//
//  Created by Mehmet ali Çavuşlu on 29.04.2025.
//

import SwiftUI
import FirebaseCore // Firebase'i başlatmak için import et

@main
struct bookSummaryApp: App {
    // UserDefaults'tan durumu okumak ve UI'ı güncellemek için @AppStorage kullan
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("hasSetHabits") var hasSetHabits: Bool = false // Yeni durum

    // Kimlik doğrulama durumunu takip et
    @State private var isAuthenticated: Bool = false // Varsayılan: false

    // --- TEST İÇİN DURUM EKLENDİ --- 
    @State private var shouldShowLoginAfterOnboardingTest = false

    // AppCoordinator'ı veya bu durumda basitçe OnboardingCoordinator'ı yönetmek için
    @StateObject private var onboardingCoordinator = OnboardingCoordinator()
    @StateObject private var loginCoordinator = LoginCoordinator()
    @StateObject private var habitsCoordinator = HabitsCoordinator() // Yeni Coordinator

    // Firebase'i uygulamanın başlangıcında yapılandır
    init() {
        FirebaseApp.configure()
        // TODO: Belki başlangıçta mevcut kullanıcıyı kontrol et?
        // isAuthenticated = Auth.auth().currentUser != nil 
    }

    var body: some Scene {
        WindowGroup {
            // Duruma göre hangi View/Coordinator'ın gösterileceğini belirle
            
            // --- TEST: Onboarding'i daima göster, bitince Login'e geç --- 
            if shouldShowLoginAfterOnboardingTest {
                // Onboarding testte bittikten sonra Login'i göster
                loginCoordinator.start()
                    .onAppear {
                        // Login bittiğinde normal akışa dönülebilir
                        loginCoordinator.didFinishAuth = {
                            self.isAuthenticated = true
                            // İsterseniz test için hasCompletedOnboarding'i de burada true yapabilirsiniz
                            // self.hasCompletedOnboarding = true 
                        }
                    }
            } else {
                // Başlangıçta veya test login henüz tetiklenmediyse Onboarding'i göster
                onboardingCoordinator.start()
                    .onAppear {
                        onboardingCoordinator.didFinishOnboarding = {
                            // Onboarding bitince durumu güncellemeyi GEÇİCİ OLARAK DEVRE DIŞI BIRAK
                            // self.hasCompletedOnboarding = true 
                            // Bunun yerine test durumunu güncelle
                            self.shouldShowLoginAfterOnboardingTest = true
                            // print("TEST: Onboarding bitti, Login tetiklenecek.") // İsteğe bağlı test mesajı
                        }
                    }
            }

            /* --- ORİJİNAL MANTIK --- 
            // --- ORİJİNAL MANTIK AKTİF --- 
            if !hasCompletedOnboarding {
                // 1. Onboarding Göster
                onboardingCoordinator.start()
                    .onAppear {
                        onboardingCoordinator.didFinishOnboarding = {
                            // Onboarding bitince durum güncelleniyor
                            self.hasCompletedOnboarding = true 
                        }
                    }
            } else if !isAuthenticated {
                // 2. Login Göster
                loginCoordinator.start()
                    .onAppear {
                        loginCoordinator.didFinishAuth = {
                            // Başarılı giriş/kayıt sonrası sadece kimlik durumunu güncelle
                            self.isAuthenticated = true
                        }
                    }
            } else if !hasSetHabits {
                // 3. Giriş yapıldı ama alışkanlıklar ayarlanmadı, Habits Göster
                habitsCoordinator.start()
                    .onAppear {
                        habitsCoordinator.didFinishHabits = {
                            // Alışkanlıklar ayarlandıktan sonra durumu güncelle
                            self.hasSetHabits = true
                        }
                    }
            } else {
                // 4. Onboarding tamamlandı, giriş yapıldı VE alışkanlıklar ayarlandı -> Ana İçerik
                // TODO: Burayı gerçek ana içerik View'ınızla değiştirin
                Text("Ana İçerik Buraya Gelecek. (Giriş Yapıldı, Alışkanlıklar Ayarlandı)")
            }
             // --- ORİJİNAL MANTIK SONU --- 
             --- ORİJİNAL MANTIK SONU --- */
        }
    }
}
