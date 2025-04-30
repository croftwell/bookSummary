//
//  ContentView.swift
//  bookSummary
//
//  Created by Mehmet ali Çavuşlu on 29.04.2025.
//

import SwiftUI

// Onboarding'de tanımlanan renkleri burada da kullanabiliriz
// Veya daha merkezi bir yere taşınabilir (örn: Color+Extensions.swift)
// Şimdilik tekrar tanımlayalım:
// let calmingBlue = Color(red: 100/255, green: 149/255, blue: 237/255) // Cornflower Blue // <- SİLİNDİ

struct ContentView: View {
    var body: some View {
        TabView {
            // 1. Sekme: Ana Sayfa / Keşfet
            HomeView()
                .tabItem {
                    Label("Keşfet", systemImage: "sparkles") // Veya "house"
                }
            
            // 2. Sekme: Kütüphanem
            LibraryView()
                .tabItem {
                    Label("Kütüphanem", systemImage: "books.vertical")
                }

            // 3. Sekme: Ara
            SearchView()
                .tabItem {
                    Label("Ara", systemImage: "magnifyingglass")
                }

            // 4. Sekme: Ayarlar / Profil
            SettingsView()
                .tabItem {
                    Label("Ayarlar", systemImage: "gearshape")
                }
        }
        // TabView'daki ikonların ve seçili sekmenin rengini ayarla
        .tint(Color.calmingBlue)
    }
}

// --- Placeholder Görünümler --- 
// Her sekme için geçici içerik görünümleri

struct HomeView: View {
    var body: some View {
        NavigationView { // Her sekme kendi navigasyonunu yönetebilir
            Text("Ana Sayfa / Keşfet İçeriği")
                .navigationTitle("Keşfet")
        }
    }
}

struct LibraryView: View {
    var body: some View {
        NavigationView {
            Text("Kütüphanem İçeriği")
                .navigationTitle("Kütüphanem")
        }
    }
}

struct SearchView: View {
    var body: some View {
        NavigationView {
            Text("Arama İçeriği")
                .navigationTitle("Ara")
            // .searchable(...) eklenebilir
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            // Genellikle Form veya List kullanılır
            Form {
                Text("Ayarlar ve Profil İçeriği")
            }
            .navigationTitle("Ayarlar")
        }
    }
}

#Preview {
    ContentView()
}
