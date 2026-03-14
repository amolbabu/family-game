Issue: GameScreenView passed isCurrentPlayerTurn: true to all CardView instances, letting any player tap any card and breaking turn order.

Analysis:
- GameLogic.generateCards creates exactly one card per player in order; card index maps to player index.
- GameScreenView's ForEach iterates over cards and used the card position index, but incorrectly marked all CardView instances as current-player-enabled.

Fix Applied:
- Updated GameScreenView to set isCurrentPlayerTurn: (gameState.currentPlayerIndex == index) when instantiating CardView, where index is the card's position in gameState.cards. This ensures only the card owned by the current player is tappable during their turn.

Files changed:
- ios/FamilyGame/FamilyGame/Views/GameScreenView.swift (CardView instantiation - conditional isCurrentPlayerTurn)
- .squad/agents/natasha-romanoff/history.md (appended learnings + fix summary)
- .squad/decisions/inbox/natasha-current-player-fix.md (this file)

Recommendations / Follow-ups:
1. Improve feedback for non-current-player cards: add a subtle overlay or tooltip like "Not your turn" so players understand why a card is disabled (currently looks like a locked card).
2. Add unit/UI tests to assert that only the current player's card is enabled and that turns advance correctly when cards are locked.
3. Consider supporting the rule variant where the current player can tap any card; if that rule is desired, centralize turn-authorization logic in GameState/TurnValidator and add configuration to GameLogic.

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
