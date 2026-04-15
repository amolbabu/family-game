# Decision: Animal Theme Addition & Random Rename to "Blind Spy"

**Date:** 2026-04-15  
**Author:** Tony Stark (Backend Developer)  
**Status:** Implemented (awaiting commit on release/1.0.0)  
**Impact:** Theme system expansion, UI string change

---

## Context

The game needed a new family-friendly theme to increase content variety. Additionally, the "Random" theme name was unclear to players about its purpose (randomly selecting from other themes). Product requested renaming to "Blind Spy" for better clarity.

---

## Decision

### 1. Added "Animal" Theme (30 words)

**Files Changed:**
- `ios/FamilyGame/FamilyGame/Resources/themes.json` — Added Animal entry
- `ios/FamilyGame/FamilyGame/Models/AppState.swift` — Added `case animal = "Animal"`
- `ios/FamilyGame/FamilyGame/Managers/ThemeManager.swift` — Added Animal to `defaultThemes()` fallback
- `ios/FamilyGame/FamilyGame/Logic/GameLogic.swift` — Added "Animal" to `concreteThemes` array

**Animal Words:**
Lion, Elephant, Penguin, Dolphin, Eagle, Tiger, Kangaroo, Giraffe, Cheetah, Panda, Octopus, Flamingo, Gorilla, Chimpanzee, Crocodile, Parrot, Shark, Butterfly, Peacock, Koala, Zebra, Wolf, Deer, Fox, Rabbit, Owl, Bear, Hawk, Seal, Camel

**Rationale:**
- All words are kid-recognizable and family-safe per PRD
- 30 words provides adequate variety (matches Place theme size)
- Animals are universally appealing across age groups

### 2. Renamed "Random" → "Blind Spy" (rawValue only)

**Files Changed:**
- `ios/FamilyGame/FamilyGame/Models/AppState.swift` — Changed `case random = "Random"` to `case random = "Blind Spy"`
- `ios/FamilyGame/FamilyGame/Logic/GameLogic.swift` — Updated `resolveTheme()` to check `"Blind Spy"` instead of `"Random"`

**Rationale:**
- "Blind Spy" clearly communicates that the spy doesn't know which theme was selected
- Preserves Swift case name `random` to avoid breaking existing code references
- Only rawValue changes, maintaining internal consistency

---

## Implementation Notes

### Data Sync Pattern Maintained

All four data sources kept in sync:
1. **themes.json** (runtime resource)
2. **AppState.Theme enum** (app model)
3. **ThemeManager.defaultThemes()** (fallback)
4. **GameLogic.resolveTheme()** (validation/resolution)

This pattern ensures:
- App works even if JSON fails to load
- Swift compiler enforces type safety via enum
- Theme selection logic remains centralized

### Testing Surface

**Areas Requiring Validation:**
- Animal theme words load correctly from JSON
- ThemeManager fallback includes Animal (for JSON load failures)
- "Blind Spy" selection correctly randomizes across all 5 themes (Place, Country, Things, Jobs, Animal)
- UI displays "Blind Spy" instead of "Random" in theme picker
- Existing themes (Place, Country, Things, Jobs) remain unaffected

**Test Files to Update:**
- Any tests hardcoding "Random" string should update to "Blind Spy"
- GameLogic tests should verify Animal theme word selection
- Theme randomization tests should confirm 5-theme distribution

---

## Coordination Notes

**Branch:** release/1.0.0  
**Commit:** Pending (Natasha working on SetupScreenView in parallel)  
**UI Impact:** Natasha's SetupScreenView will show "Blind Spy" in picker instead of "Random"

---

## Consequences

### Positive
- Increased content variety with Animal theme
- Clearer user-facing terminology ("Blind Spy" vs "Random")
- Maintains architectural pattern for theme data sync

### Neutral
- Theme enum now has 6 cases (5 concrete + 1 special)
- Random selection now chooses from 5 themes instead of 4

### Risks
- None identified (backward compatible at Swift level, UI string change only)

---

## Future Considerations

**Theme Expansion Path:**
- Pattern established for adding new themes (4-file sync)
- Could add: Sports, Food, Colors, Movies, etc.
- Consider externalizing theme validation into unit tests

**Blind Spy Enhancement Ideas:**
- UI could show "Blind Spy (Random)" with tooltip
- Analytics: track which themes get selected when Blind Spy is chosen
- Future: Blind Spy could exclude recently-played themes for variety
