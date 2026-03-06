import XCTest
@testable import FamilyGame

final class PlayerTests: XCTestCase {
    
    // MARK: - Player Initialization Tests
    
    /// Test Player initialization with name
    func testPlayerInitialization() {
        let player = Player(name: "Alice")
        
        XCTAssertEqual(player.name, "Alice")
        XCTAssertEqual(player.role, .normal)
        XCTAssertNotNil(player.id)
    }
    
    /// Test Player with spy role
    func testPlayerWithSpyRole() {
        let player = Player(name: "Bob", role: .spy)
        
        XCTAssertEqual(player.name, "Bob")
        XCTAssertEqual(player.role, .spy)
    }
    
    /// Test Player ID uniqueness
    func testPlayerIDUniqueness() {
        let player1 = Player(name: "Charlie")
        let player2 = Player(name: "Charlie")
        
        XCTAssertNotEqual(player1.id, player2.id, "Different players should have unique IDs")
    }
    
    /// Test Player with custom UUID
    func testPlayerWithCustomUUID() {
        let uuid = UUID()
        let player = Player(id: uuid, name: "David")
        
        XCTAssertEqual(player.id, uuid)
    }
    
    /// Test Player Identifiable protocol
    func testPlayerIdentifiable() {
        let player = Player(name: "Eve")
        let playerId = player.id
        
        XCTAssertEqual(player.id, playerId)
    }
    
    // MARK: - Player Role Tests
    
    /// Test normal player role
    func testNormalPlayerRole() {
        let player = Player(name: "Frank", role: .normal)
        
        XCTAssertEqual(player.role, .normal)
    }
    
    /// Test spy player role
    func testSpyPlayerRole() {
        let player = Player(name: "Grace", role: .spy)
        
        XCTAssertEqual(player.role, .spy)
    }
    
    /// Test role assignment for player collections
    func testMultiplePlayersWithRoles() {
        let players = [
            Player(name: "Player 1", role: .normal),
            Player(name: "Player 2", role: .normal),
            Player(name: "Player 3", role: .spy)
        ]
        
        let spyCount = players.filter { $0.role == .spy }.count
        let normalCount = players.filter { $0.role == .normal }.count
        
        XCTAssertEqual(spyCount, 1)
        XCTAssertEqual(normalCount, 2)
    }
    
    // MARK: - Player Name Tests
    
    /// Test player name storage
    func testPlayerNameStorage() {
        let name = "Alice"
        let player = Player(name: name)
        
        XCTAssertEqual(player.name, name)
    }
    
    /// Test various player names
    func testVariousPlayerNames() {
        let names = ["Alice", "Bob", "Charlie", "David", "Eve", "Frank", "Grace", "Henry"]
        
        for name in names {
            let player = Player(name: name)
            XCTAssertEqual(player.name, name)
        }
    }
    
    /// Test player name with special characters
    func testPlayerNameWithSpecialCharacters() {
        let names = ["Player 1", "José", "Müller", "O'Brien"]
        
        for name in names {
            let player = Player(name: name)
            XCTAssertEqual(player.name, name)
        }
    }
    
    // MARK: - Player Coding (Serialization)
    
    /// Test Player encoding and decoding
    func testPlayerCoding() throws {
        let original = Player(name: "Alice", role: .normal)
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Player.self, from: encoded)
        
        XCTAssertEqual(original.id, decoded.id)
        XCTAssertEqual(original.name, decoded.name)
        XCTAssertEqual(original.role, decoded.role)
    }
    
    /// Test Player with spy role coding
    func testSpyPlayerCoding() throws {
        let original = Player(name: "Bob", role: .spy)
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Player.self, from: encoded)
        
        XCTAssertEqual(original.role, decoded.role)
        XCTAssertEqual(original.name, decoded.name)
    }
    
    /// Test array of Players coding
    func testPlayerArrayCoding() throws {
        let players = [
            Player(name: "Alice", role: .normal),
            Player(name: "Bob", role: .normal),
            Player(name: "Charlie", role: .spy)
        ]
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(players)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode([Player].self, from: encoded)
        
        XCTAssertEqual(players.count, decoded.count)
        for (original, decodedPlayer) in zip(players, decoded) {
            XCTAssertEqual(original.name, decodedPlayer.name)
            XCTAssertEqual(original.role, decodedPlayer.role)
        }
    }
    
    /// Test Player with different names coding
    func testMultiplePlayersCoding() throws {
        let players = [
            Player(name: "Player 1", role: .normal),
            Player(name: "Player 2", role: .normal),
            Player(name: "Player 3", role: .normal),
            Player(name: "Player 4", role: .spy)
        ]
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(players)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode([Player].self, from: encoded)
        
        for i in 0..<players.count {
            XCTAssertEqual(players[i].name, decoded[i].name)
            XCTAssertEqual(players[i].role, decoded[i].role)
        }
    }
    
    // MARK: - Player Role Enumeration Tests
    
    /// Test PlayerRole.normal
    func testPlayerRoleNormal() {
        let role = PlayerRole.normal
        XCTAssertEqual(role, .normal)
    }
    
    /// Test PlayerRole.spy
    func testPlayerRoleSpy() {
        let role = PlayerRole.spy
        XCTAssertEqual(role, .spy)
    }
    
    /// Test PlayerRole inequality
    func testPlayerRoleInequality() {
        let normal = PlayerRole.normal
        let spy = PlayerRole.spy
        
        XCTAssertNotEqual(normal, spy)
    }
    
    // MARK: - Game Setup Tests with Players
    
    /// Test game can be initialized with players
    func testGameInitializationWithPlayers() {
        let players = [
            Player(name: "Alice"),
            Player(name: "Bob"),
            Player(name: "Charlie")
        ]
        
        var gameState = GameState(players: players, theme: "Country", word: "France")
        
        XCTAssertEqual(gameState.players.count, 3)
        XCTAssertEqual(gameState.players[0].name, "Alice")
        XCTAssertEqual(gameState.players[1].name, "Bob")
        XCTAssertEqual(gameState.players[2].name, "Charlie")
    }
    
    /// Test player access during gameplay
    func testPlayerAccessDuringGameplay() {
        let players = [
            Player(name: "Player 1"),
            Player(name: "Player 2"),
            Player(name: "Player 3")
        ]
        var gameState = GameState(players: players, theme: "Place", word: "Paris")
        
        XCTAssertEqual(gameState.currentPlayerIndex, 0)
        let currentPlayer = gameState.players[gameState.currentPlayerIndex]
        XCTAssertEqual(currentPlayer.name, "Player 1")
        
        gameState.nextPlayer()
        let nextPlayer = gameState.players[gameState.currentPlayerIndex]
        XCTAssertEqual(nextPlayer.name, "Player 2")
    }
    
    /// Test all players can be accessed sequentially
    func testSequentialPlayerAccess() {
        let players = [
            Player(name: "Alice"),
            Player(name: "Bob"),
            Player(name: "Charlie"),
            Player(name: "David")
        ]
        var gameState = GameState(players: players, theme: "Things", word: "Bicycle")
        
        let expectedNames = ["Alice", "Bob", "Charlie", "David"]
        
        for expectedName in expectedNames {
            let currentPlayer = gameState.players[gameState.currentPlayerIndex]
            XCTAssertEqual(currentPlayer.name, expectedName)
            gameState.nextPlayer()
        }
    }
    
    // MARK: - Family-Friendly Player Names
    
    /// Test that player names can be customized and updated
    func testPlayerNameCustomization() {
        let player = Player(name: "Default Name")
        XCTAssertEqual(player.name, "Default Name")
        
        // Player names should be stored as-is
        let customPlayer = Player(name: "My Custom Name")
        XCTAssertEqual(customPlayer.name, "My Custom Name")
    }
    
    /// Test that player objects maintain identity
    func testPlayerIdentityMaintenance() {
        let player1 = Player(name: "Alice")
        let player1Copy = player1
        
        XCTAssertEqual(player1.id, player1Copy.id)
        XCTAssertEqual(player1.name, player1Copy.name)
    }
    
    // MARK: - Edge Cases
    
    /// Test minimum player setup
    func testMinimumPlayerCount() {
        let players = [
            Player(name: "Player 1"),
            Player(name: "Player 2")
        ]
        var gameState = GameState(players: players, theme: "Country", word: "Brazil")
        
        XCTAssertEqual(gameState.players.count, 2)
    }
    
    /// Test maximum player setup
    func testMaximumPlayerCount() {
        let players = (1...8).map { Player(name: "Player \($0)") }
        var gameState = GameState(players: players, theme: "Place", word: "Sydney")
        
        XCTAssertEqual(gameState.players.count, 8)
        
        for i in 0..<8 {
            XCTAssertEqual(gameState.players[i].name, "Player \(i + 1)")
        }
    }
}
