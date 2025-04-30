import Foundation
import FirebaseAuth // Firebase User bilgisini kullanmak için

// Uygulama içindeki kullanıcıyı temsil eden model.
// Firebase User nesnesini veya Firestore verilerini temel alabilir.
struct AppUser: Identifiable, Codable {
    let id: String      // Firebase UID
    var name: String?     // Kullanıcının adı (Firebase profilden)
    let email: String?    // Kullanıcının e-postası (Firebase profilden)
    // TODO: Profil resmi URL'si, favori türler, okuma istatistikleri gibi
    // Firestore'dan veya başka kaynaklardan gelecek ek alanlar buraya eklenebilir.
    // var profileImageURL: URL?
    // var favoriteGenres: [String]?
    
    // Firebase User nesnesinden AppUser oluşturmak için kolaylaştırıcı initializer (isteğe bağlı)
    init?(firebaseUser: User) {
        self.id = firebaseUser.uid
        self.name = firebaseUser.displayName
        self.email = firebaseUser.email
        // Diğer alanlar Firestore'dan vb. doldurulabilir
    }
    
    // Test veya varsayılan durumlar için (isteğe bağlı)
    init(id: String, name: String?, email: String?) {
        self.id = id
        self.name = name
        self.email = email
    }
    
    // Belki varsayılan boş bir kullanıcı?
    static var empty: AppUser {
        AppUser(id: "", name: nil, email: nil)
    }
} 