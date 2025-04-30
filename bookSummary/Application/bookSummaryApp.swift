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

    var body: some Scene {
        WindowGroup {
            // Onboarding tamamlandıysa ContentView'ı, değilse yeni OnboardingView'ı göster.
            /* // <- Test için kontrolü kaldırıyoruz
            if hasCompletedOnboarding {
                ContentView() // Ana içeriğiniz
            } else {
                OnboardingView() // Yeni SwiftUI Onboarding Ekranı
            }
            */
            
            // Test süresince her zaman OnboardingView'ı göster
            OnboardingView()
        }
    }
}
