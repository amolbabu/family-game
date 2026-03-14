Reproduction steps for diagnostic logging:

1. Open the app in Xcode and select a simulator or device.
2. Clean build folder (Product → Clean Build Folder) to ensure latest code is run.
3. Run the app (Cmd+R) and open the Xcode Console (Debug area).
4. Reproduce the issue:
   - On the home screen, set number of players and theme as usual.
   - Tap 'Start' to begin the game (this triggers GameScreenView.initializeGameState and GameLogic.generateCards).
   - When the card grid appears, observe whether cards are face-down or already revealed.
   - If a card is tapped, observe the logs emitted by CardView.tap and the CardRevealSheet actions.

Logs to capture & what to watch for:
- Look for lines prefixed with [TRACE] and timestamps.
- GameLogic.generateCards: Creating card X - spy: true/false, isRevealed: false
  - If any card shows isRevealed: true here, that indicates generation is incorrect.
- GameScreen.initializeGameState: Before generation - existing cards count: N
  - If there are pre-existing cards with isRevealed: true, that suggests state was not reset before Start.
- GameScreen.initializeGameState: After generation - Created card X - content: ..., isRevealed: false, isLocked: false
  - Confirms post-generation state.
- CardView: Rendering card X - isRevealed: true/false, isLocked: true/false
  - If rendering shows isRevealed: true immediately after generation, note timestamp to compare with generation logs.
- CardView.tap: Tapped index X - content: ..., isRevealed: ..., isLocked: ..., isCurrentPlayerTurn: ...
  - Use this to trace tap-handling correctness.

Expected signals:
- For a correct face-down start, GameLogic.generateCards and GameScreen.initializeGameState logs should show isRevealed: false for all cards, and CardView rendering logs should also show isRevealed: false.
- If CardView rendering shows isRevealed: true but generation logs show false, look for a race or a state mutation elsewhere between generation and render.

Capture the full console output and attach when reporting back.
