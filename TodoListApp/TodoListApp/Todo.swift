import Foundation

struct Todo: Codable, Identifiable {
    var id: UUID?
    var title: String
    var complete: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, title, complete
    }
}
