# Bruce Banner — QA History

## Learnings

- Player count validation test patterns:
  - Use direct Int(String) conversions to verify parsing behavior for inputs (numeric, leading zeros, whitespace, non-numeric, special chars).
  - Validate both UI-level form validity (all player name fields non-empty) and GameLogic bounds (generateCards throws for <= 0).
  - Include boundary tests for min and max values and repeated state transitions.

- SwiftUI TextField testing approach:
  - Since SwiftUI views often use @Environment for AppState, replicate view validation logic in tests by asserting AppState-derived predicates (e.g., allSatisfy on playerNames) rather than attempting to mount views.
  - Use direct mutation of AppState to simulate user input and verify derived UI state (disabled/enabled button states).

- Animation verification in tests:
  - Execute state transitions inside withAnimation blocks to exercise any animation-driven code paths and ensure no crashes occur.
  - Prefer asserting final state changes post-animation rather than trying to capture intermediate animation frames in unit tests.
