import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Keşfet", systemImage: "sparkles")
                }
            
            LibraryView()
                .tabItem {
                    Label("Kütüphanem", systemImage: "books.vertical")
                }

            SearchView()
                .tabItem {
                    Label("Ara", systemImage: "magnifyingglass")
                }

            SettingsView()
                .tabItem {
                    Label("Ayarlar", systemImage: "gearshape")
                }
        }
        .tint(Theme.calmingBlue) // Renkler merkezi Theme dosyasından kullanıldı
    }
}

// MARK: - Placeholder Sekme Görünümleri

struct HomeView: View {
    var body: some View {
        NavigationView {
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
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Form {
                Text("Ayarlar ve Profil İçeriği")
            }
            .navigationTitle("Ayarlar")
        }
    }
}

// MARK: - Önizleme

#Preview {
    ContentView()
}
