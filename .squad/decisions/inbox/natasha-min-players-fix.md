# Decision: Minimum Player Count Validation (2 Players)

**Date:** 2026-03-25  
**Author:** Natasha Romanoff (Frontend Developer)  
**Status:** ✅ Implemented  
**Related:** GitHub Issue #3, SetupScreenView.swift

---

## Context

The SPY WORD game requires a minimum of 2 players to function correctly (at least 1 spy and 1 civilian). Prior to this fix, SetupScreenView allowed users to start a game with only 1 player, which would result in broken game logic.

## Problem

**Current behavior:**
- User can enter "1" in the player count field
- Start button becomes enabled
- User can tap Start and begin a 1-player game (broken state)

**Expected behavior:**
- User can enter "1" (to see validation feedback)
- Start button should be disabled when count < 2
- Clear inline hint should explain why they cannot start

## Decision

Implement two-tier validation:

1. **Input validation (`isValidCount`):** Allow 1-12 range for typing
2. **Action validation (`canStartGame`):** Enforce 2-12 range for starting

This separation allows users to see "1" as valid input while preventing the broken game state.

## Implementation

### Code Changes (SetupScreenView.swift)

**1. Added `canStartGame` computed property:**
```swift
var canStartGame: Bool {
    if let v = Int(playerCountInput), v >= 2 && v <= 12 {
        return true
    }
    return false
}
```

**2. Inline hint below player count input:**
```swift
if let v = Int(playerCountInput), v == 1 {
    Text("Minimum 2 players required")
        .font(.caption)
        .foregroundColor(.secondary)
}
```

**3. Start button updates:**
- Changed validation check: `isValidCount` → `canStartGame`
- Added opacity modifier: `.opacity(canStartGame ? 1.0 : 0.5)`
- Updated accessibility hint: "Enter at least 2 players to start"
- Improved tap error message: "Minimum 2 players required"

## Rationale

### Why not just change the minimum to 2?
- Users need to SEE the hint to understand why they can't proceed
- Preventing input of "1" would hide the validation message
- Better UX: let them type any number, then explain constraints

### Why separate validation properties?
- `isValidCount`: UI affordance (is the input valid?)
- `canStartGame`: Business logic (can the game actually start?)
- Separation of concerns makes code more maintainable

### Why inline hint instead of modal alert?
- Less intrusive, appears immediately as user types
- Contextual placement (near the input that needs correction)
- Matches modern mobile UX patterns (inline validation)

## Alternatives Considered

1. **Modal alert on Start tap** — Rejected (too disruptive, poor UX)
2. **Disable input at 1** — Rejected (hides the validation message)
3. **Show hint always** — Rejected (unnecessary noise when count ≥ 2)

## Visual Design Choices

- **Font:** `.caption` (small, non-intrusive)
- **Color:** `.secondary` (muted, not alarming like red error text)
- **Placement:** Directly below player count field (contextual)
- **Visibility:** Only when `playerCount == 1` (conditional rendering)

## Accessibility

- VoiceOver hint updated: "Enter at least 2 players to start"
- System colors used (automatic dark mode support)
- Button disabled state clearly communicated visually and semantically

## Impact

- **User Experience:** Prevents broken game state, clear feedback
- **Code Quality:** Clean separation of input vs. action validation
- **Maintainability:** Easy to adjust minimum player count in future (single property)

## Verification

✅ Committed: Git SHA 71211051  
✅ GitHub Issue #3 closed  
✅ Pushed to release/1.0.0 branch

## Future Considerations

- If game modes with 1-player support are added, this validation can be made dynamic
- Could add similar inline hints for maximum player count (currently 12)
- Pattern can be reused for other form validations in the app
