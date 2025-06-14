import Foundation
import FirebaseAuth

/// Uygulama içindeki kullanıcıyı temsil eden model.
/// Firebase User nesnesinden veya Firestore'dan gelen verilerle oluşturulabilir.
struct AppUser: Identifiable, Codable, Hashable {
    let id: String      // Firebase UID
    var name: String?
    let email: String?
    
    // Gelecekte eklenebilecek alanlar:
    // var profileImageURL: URL?
    // var favoriteGenres: [String]?

    /// Firebase User nesnesinden bir AppUser oluşturur.
    init?(firebaseUser: User) {
        self.id = firebaseUser.uid
        self.name = firebaseUser.displayName
        self.email = firebaseUser.email
    }
    
    /// Test veya manuel oluşturma için initializer.
    init(id: String, name: String?, email: String?) {
        self.id = id
        self.name = name
        self.email = email
    }
    
    /// Boş bir kullanıcıyı temsil eden statik bir örnek.
    static let empty = AppUser(id: "", name: nil, email: nil)
}
