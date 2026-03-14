Logging implementation (diagnostic):

- Added detailed TRACE prints to:
  - GameLogic.generateCards() — logs each created card with timestamp, spy flag, and isRevealed
  - GameScreenView.initializeGameState() — logs cards before generation and after generation with full state
  - CardView.body and CardView.tap — logs rendering and tap events with content description and state

Next steps:
- Run the app in Xcode, click Start, then follow the reproduction steps in the decision file to capture console output.
- If cards still appear revealed on Start, capture logs and forward to devs for analysis. Look for unexpected isRevealed: true at generation time.
