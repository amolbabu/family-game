# Natasha - iOS Developer History

## Learnings

### 2024-03-24: SwiftUI Button Tap Issue in Forms
**Problem:** Theme buttons (Place, Things) in SetupScreenView were not responding to taps, while Random button seemed to work.

**Root Cause:** In SwiftUI, `Button` views inside a `Form` have their tap events intercepted by the Form's list row system. When buttons are nested inside VStack/HStack within a Section, the Form treats the whole container as one row and doesn't properly route taps to individual buttons.

**Solution:** Added `.buttonStyle(.plain)` modifier to all theme buttons (Place, Country, Things, and Random). This tells SwiftUI to use plain button style which allows proper tap handling inside Forms.

**Key Takeaway:** Always use `.buttonStyle(.plain)` for buttons inside SwiftUI Forms when you want direct button tap behavior without Form's row interaction interference.

**Files Modified:** 
- `ios/FamilyGame/FamilyGame/Views/SetupScreenView.swift` - Added `.buttonStyle(.plain)` to 4 theme buttons
