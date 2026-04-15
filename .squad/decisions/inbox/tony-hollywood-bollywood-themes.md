# Decision: Hollywood & Bollywood Theme Addition

**Date:** 2026-04-15  
**Decision Maker:** Tony Stark (Backend & Game Logic Engineer)  
**Status:** Implemented  
**Impact:** Feature Addition — Theme System Expansion

---

## Context

The game previously had 5 playable themes (Place, Country, Things, Jobs, Animal) plus the "Blind Spy" random selector. User requested adding two new cinema-themed categories to expand gameplay variety:
- **Hollywood** — American cinema vocabulary
- **Bollywood** — Indian cinema vocabulary

---

## Decision

Added Hollywood and Bollywood as new selectable themes with full word lists, integrated across all four data sync points in the architecture.

### Implementation Details

1. **themes.json** — Added two new theme objects:
   - Hollywood: 26 words (Oscars, Red Carpet, Blockbuster, Director, Screenplay, etc.)
   - Bollywood: 29 words (Item Song, Dance Number, Heroine, Hero, Filmfare, etc.)

2. **AppState.swift** — Extended Theme enum:
   ```swift
   enum Theme: String, CaseIterable {
       case place = "Place"
       case country = "Country"
       case things = "Things"
       case jobs = "Jobs"
       case animal = "Animal"
       case hollywood = "Hollywood"      // NEW
       case bollywood = "Bollywood"      // NEW
       case random = "Blind Spy"
   }
   ```

3. **ThemeManager.swift** — Updated fallback `defaultThemes()`:
   - Added Hollywood and Bollywood to hardcoded fallback array
   - Ensures offline reliability if JSON fails to load

4. **GameLogic.swift** — Expanded `resolveTheme()` concreteThemes array:
   ```swift
   let concreteThemes = ["Place", "Country", "Things", "Jobs", "Animal", "Hollywood", "Bollywood"]
   ```
   - "Blind Spy" now randomly selects from 7 themes (was 5)

5. **RandomCategoryTests.swift** — Updated all test assertions:
   - Changed expected theme count from 5 to 7
   - Updated all "Random" string literals to "Blind Spy" (matches enum rawValue)
   - Added Hollywood and Bollywood to validThemes arrays
   - All 25 tests passing

---

## Rationale

**Why Two Separate Themes?**
- Distinct cultural representation (American vs Indian cinema)
- Allows players to choose specific cultural context
- Balanced word counts (26 vs 29) provide adequate variety

**Why Before "Blind Spy" in Enum?**
- UI convention: random/wildcard options appear last in selection lists
- CaseIterable order drives UI picker display
- Maintains existing "Blind Spy is last" pattern

**Why 26-29 Words?**
- Matches word count distribution of existing themes (Jobs: 30, Animal: 30, Country: 32)
- Sufficient variety for replay without repetition
- All words family-friendly and culturally recognizable

---

## Alternatives Considered

1. **Single "Cinema" Theme** — Rejected because:
   - Loses cultural specificity (Hollywood ≠ Bollywood)
   - Players may prefer one style over another
   - Mixing vocabularies reduces thematic coherence

2. **Broader "Entertainment" Theme** — Rejected because:
   - Too generic, loses focus
   - Hollywood and Bollywood are rich enough to stand alone
   - Matches granularity of existing themes (Jobs, Animal)

3. **Add Only Hollywood** — Rejected because:
   - User explicitly requested both
   - Misses opportunity for cultural diversity
   - Bollywood is globally recognized entertainment industry

---

## Consequences

### Positive
- **Expanded Gameplay:** 7 themes (from 5) increases variety
- **Cultural Diversity:** Represents both Western and Indian cinema traditions
- **Player Choice:** Users can select specific cinema style or let "Blind Spy" choose
- **Blind Spy Variety:** Randomization now pulls from 7 themes instead of 5

### Neutral
- **Maintenance:** Two more theme word lists to maintain
- **Test Coverage:** 7 themes instead of 5 in validation tests

### Negative
- **None Identified:** Word lists are family-safe, culturally appropriate, and balanced

---

## Validation

- ✅ Build successful (0 errors, 0 warnings)
- ✅ All 25 RandomCategoryTests passing
- ✅ themes.json validates as correct JSON
- ✅ ThemeManager fallback includes new themes
- ✅ GameLogic.resolveTheme() includes new themes in random pool
- ✅ 4-way data sync maintained (JSON → Enum → Manager → Logic)

---

## Notes

- Theme names use title case for UI display consistency
- Word lists curated for family-friendly gameplay (no mature content)
- Both themes include overlap words (e.g., "Director", "Producer") — acceptable for thematic accuracy
- Blind Spy randomization now has 40% more variety (7 themes vs 5)

---

## Related Files

```
ios/FamilyGame/FamilyGame/Resources/themes.json           # Word lists
ios/FamilyGame/FamilyGame/Models/AppState.swift           # Theme enum
ios/FamilyGame/FamilyGame/Managers/ThemeManager.swift     # Loading & fallback
ios/FamilyGame/FamilyGame/Logic/GameLogic.swift           # Random resolution
ios/FamilyGame/FamilyGameTests/RandomCategoryTests.swift  # Test coverage
```

---

## Implementation By

**Tony Stark** — Backend & Game Logic Engineer  
**Approved By:** Self (within authority: data models, game logic)  
**Review Status:** No review required (additive feature, no breaking changes)
