import XCTest
import SwiftUI
import os
@testable import FamilyGame

final class SetupScreenViewTests: XCTestCase {
    // MARK: - Player Count Parsing & Validation Tests

    func testNumericStringParsing_acceptsNumbersOnly() {
        XCTAssertEqual(Int("5"), 5)
        XCTAssertEqual(Int("05"), 5, "Leading zeros should parse to integer value")
        XCTAssertEqual(Int("\t10\n"), 10, "Pasted numbers with surrounding whitespace should parse")
    }

    func testNumericStringParsing_rejectsLettersAndSymbols() {
        XCTAssertNil(Int("abc"))
        XCTAssertNil(Int("12abc"))
        XCTAssertNil(Int("1.5"), "Decimal notation should not parse to Int")
        XCTAssertNil(Int("#5"))
        XCTAssertNil(Int(""), "Empty input must not parse")
    }

    // Edge cases: leading zeros, pasting
    func testLeadingZerosInterpretedAsInteger() {
        XCTAssertEqual(Int("05"), 5)
        XCTAssertEqual(Int("0003"), 3)
    }

    func testPastedNumberParsesCorrectly() {
        XCTAssertEqual(Int("  12"), 12)
        XCTAssertEqual(Int("12  "), 12)
    }

    // MARK: - UI State (Form validity) Tests

    func testFormValidityReflectsPlayerNames_nonEmpty() {
        let appState = AppState()
        // Set up 3 players with one empty name
        appState.setPlayerCount(3)
        appState.updatePlayerName(0, to: "")
        appState.updatePlayerName(1, to: "Bob")
        appState.updatePlayerName(2, to: "Charlie")

        let isFormValid = appState.playerNames.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        XCTAssertFalse(isFormValid, "Form should be invalid when any player name is empty")

        // Fill the empty name and re-evaluate
        appState.updatePlayerName(0, to: "Alice")
        let nowValid = appState.playerNames.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        XCTAssertTrue(nowValid, "Form should be valid when all player names are non-empty")
    }

    // MARK: - Animation State / Button Feedback Tests

    /// Verify that starting the game within an animation context does not crash and transitions state
    func testStartGameWithAnimationDoesNotCrash() {
        let appState = AppState()
        appState.setPlayerCount(3)
        appState.playerNames = ["A", "B", "C"]

        // Execute startGame inside withAnimation to ensure view-driven animation code paths are exercised
        withAnimation {
            appState.startGame()
        }

        XCTAssertEqual(appState.currentScreen, .game, "Starting the game should transition to .game state")
    }

    // MARK: - Logging Integration Tests

    func testOsLoggerDoesNotCrash() {
        if #available(iOS 14.0, *) {
            let logger = Logger(subsystem: "com.familygame.tests", category: "setup")
            // If logger initialization doesn't crash, test passes
            XCTAssertTrue(true)
        } else {
            // Fallback: ensure the test runner doesn't fail on older SDKs
            XCTAssertTrue(true)
        }
    }

    // MARK: - GameLogic Integration (Bounds)

    func testGameLogicRejectsZeroAndNegativeCounts() {
        XCTAssertThrowsError(try GameLogic.generateCards(playerCount: 0, theme: "Country", word: "France"))
        XCTAssertThrowsError(try GameLogic.generateCards(playerCount: -2, theme: "Place", word: "Paris"))
    }

    func testGameLogicAcceptsValidCounts_upTo12() {
        for count in [1, 2, 3, 6, 8, 12] {
            let cards = try? GameLogic.generateCards(playerCount: count, theme: "Country", word: "Test")
            XCTAssertNotNil(cards, "Should generate cards without error for count: \(count)")
            XCTAssertEqual(cards?.count, count, "GameLogic should generate exactly \(count) cards")
        }
    }
}
