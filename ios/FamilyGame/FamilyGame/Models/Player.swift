import Foundation

enum PlayerRole: Equatable {
    case normal
    case spy
}

struct Player: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let role: PlayerRole
    
    enum CodingKeys: String, CodingKey {
        case id, name, role
    }
    
    init(id: UUID = UUID(), name: String, role: PlayerRole = .normal) {
        self.id = id
        self.name = name
        self.role = role
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(role == .spy ? "spy" : "normal", forKey: .role)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let roleString = try container.decode(String.self, forKey: .role)
        role = roleString == "spy" ? .spy : .normal
    }
}
