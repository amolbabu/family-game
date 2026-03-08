import Foundation

enum CardContent: Codable, Equatable {
    case word(String)
    case spy
    
    enum CodingKeys: String, CodingKey {
        case type, value
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .word(let wordValue):
            try container.encode("word", forKey: .type)
            try container.encode(wordValue, forKey: .value)
        case .spy:
            try container.encode("spy", forKey: .type)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        if type == "spy" {
            self = .spy
        } else if type == "word" {
            let value = try container.decode(String.self, forKey: .value)
            self = .word(value)
        } else {
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown card content type")
        }
    }
}

struct Card: Identifiable, Codable, Equatable {
    let id: UUID
    let content: CardContent
    var isRevealed: Bool
    var isLocked: Bool
    
    init(id: UUID = UUID(), content: CardContent, isRevealed: Bool = false, isLocked: Bool = false) {
        self.id = id
        self.content = content
        self.isRevealed = isRevealed
        self.isLocked = isLocked
    }
}
