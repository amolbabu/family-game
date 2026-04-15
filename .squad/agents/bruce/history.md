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

## Learnings

### 2026-04-15: TurnIndicatorView Stats Block Review
**Context:** User frustrated with ping-pong on stats sizing (too large/too small iterations). Natasha made latest change to compact single-line layout.

**What I Evaluated:**
1. Font sizes (12pt numbers, 11pt labels)
2. Single-line HStack layout (icon + number + label)
3. Vertical space usage
4. Visual appropriateness for card reveal screen
5. Layout behavior with Spacer()

**Key Findings:**
- ✅ Font sizes are appropriate - 12pt/11pt is readable on iPhone without being oversized
- ✅ Single-line compact layout makes sense for card reveal screen
- ✅ Vertical space usage (~24pt with padding) is reasonable
- ⚠️ Trailing Spacer() on line 83 will push all stats to the left, creating visual imbalance

**Verdict:** ⚠️ NEEDS TWEAK
- Minor issue: Remove or balance the Spacer() to fix left-alignment problem
- Otherwise the implementation is solid - appropriate sizing and clean layout

**QA Philosophy Applied:**
- Gave honest assessment, not cheerleading
- Identified specific line numbers and exact font sizes
- Distinguished between what works and what needs fixing
- Provided clear severity assessment (LOW priority visual polish)
- Acknowledged good work while being precise about the remaining issue

