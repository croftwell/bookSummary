//
//  bookSummaryApp.swift
//  bookSummary
//
//  Created by Mehmet ali Çavuşlu on 29.04.2025.
//

import SwiftUI

@main
struct bookSummaryApp: App {
    // UserDefaults'tan durumu okumak için @AppStorage kullanıyoruz.
    // @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false // <- Test için geçici olarak yorum satırı veya kontrolü kaldır

    // Onboarding durumunu takip etmek için geçici State
    @State private var hasCompletedOnboarding: Bool = false

    // AppCoordinator'ı veya bu durumda basitçe OnboardingCoordinator'ı yönetmek için
    // Eğer AppCoordinator yapısı kurulsaydı, onu burada başlatırdık.
    // Şimdilik OnboardingCoordinator'ı doğrudan yönetelim.
    @StateObject private var onboardingCoordinator = OnboardingCoordinator()

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                // Onboarding tamamlandıktan sonra gösterilecek ana içerik
                // Şimdilik basit bir Text gösterelim.
                Text("Onboarding Tamamlandı! Ana İçerik Buraya Gelecek.")
            } else {
                // OnboardingCoordinator'ın başlangıç view'ını göster
                onboardingCoordinator.start()
                    .onAppear {
                        // Coordinator'ın bitiş olayını dinle
                        onboardingCoordinator.didFinishOnboarding = {
                            // Onboarding tamamlandığında durumu güncelle
                            self.hasCompletedOnboarding = true
                            // Gerçek uygulamada AppStorage'a da kaydedilebilir.
                            // UserDefaults.standard.setValue(true, forKey: "hasCompletedOnboarding")
                        }
                    }
            }
        }
    }
}
