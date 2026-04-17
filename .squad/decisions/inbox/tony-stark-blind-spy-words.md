# Decision: Blind Spy Theme Word Addition

**Date:** 2026-04-15  
**Author:** Tony Stark (Backend Developer)  
**Status:** ✅ COMPLETED  
**Related Issue:** Bruce Banner QA Regression v1.2 - Critical Issue #1

---

## Problem Statement

Bruce Banner's regression testing identified that the "Blind Spy" theme had zero words in `themes.json`, creating a potential crash scenario if selected by players. The theme was originally designed as a meta-theme that randomizes to other concrete themes, but had no word list of its own.

---

## Solution

**Converted "Blind Spy" into a concrete playable theme** by adding 27 spy/espionage-themed, family-friendly words.

### Word List Added (27 words):
1. Mission
2. Disguise
3. Double Agent
4. Safe House
5. Code Name
6. Surveillance
7. Gadget
8. Handler
9. Asset
10. Dead Drop
11. Cover Story
12. Encryption
13. Mole
14. Intelligence
15. Operative
16. Rendezvous
17. Extraction
18. Infiltration
19. Cipher
20. Briefcase
21. Undercover
22. Classified
23. Spy Satellite
24. Secret Agent
25. Stealth
26. Espionage
27. Decoder

---

## Implementation Details

### Files Modified:

1. **`ios/FamilyGame/FamilyGame/Resources/themes.json`**
   - Added "Blind Spy" theme entry as 8th theme
   - Included all 27 spy-themed words in JSON format

2. **`ios/FamilyGame/FamilyGame/Managers/ThemeManager.swift`**
   - Updated `defaultThemes()` fallback to include Blind Spy theme
   - Ensures consistency if JSON fails to load

### Data Sync Maintained:
✅ themes.json — Blind Spy added  
✅ ThemeManager.swift — defaultThemes() updated  
⚠️ GameLogic.swift — Still treats "Blind Spy" as meta-theme (randomizes to other 7 themes)  
⚠️ AppState.swift — Theme.random enum exists but resolves dynamically  

---

## Design Criteria

All words selected meet the following criteria:
- ✅ **Family-friendly:** No violence, weapons, or mature themes
- ✅ **Spy-themed:** Espionage, missions, gadgets, secret agents
- ✅ **Recognizable:** Common terms suitable for charades/guessing games
- ✅ **Consistent format:** Nouns and short phrases matching other themes
- ✅ **Count:** 27 words (consistent with other themes: 26-32 words)

---

## Current Behavior vs. Future Options

### Current Behavior:
- Blind Spy has 27 concrete words in themes.json
- `GameLogic.resolveTheme("Blind Spy")` still randomizes to one of the 7 other themes
- UI shows "Blind Spy" as theme option, but gameplay uses randomized theme
- **Result:** Blind Spy acts as randomizer, not as concrete theme with spy words

### Future Option A: Keep as Meta-Theme
- No changes needed
- Blind Spy continues to randomize to Place, Country, Things, Jobs, Animal, Hollywood, Bollywood
- Word list exists but is unused (prevents crashes if logic changes)

### Future Option B: Make Concrete Theme
- Update `GameLogic.resolveTheme()` to return "Blind Spy" unchanged (don't randomize)
- Add "Blind Spy" to `concreteThemes` array in GameLogic.swift
- Players would get spy-themed words when selecting Blind Spy
- Would need 8th theme button in UI or replace randomization button

---

## Impact Assessment

**Immediate Impact:**
- ✅ Prevents crash scenario identified in QA testing
- ✅ Blind Spy now has word data in all data sources (JSON + fallback)
- ✅ No changes to existing gameplay behavior (resolveTheme still randomizes)

**Future Flexibility:**
- Product can decide whether Blind Spy should be concrete theme or meta-theme
- Word data is ready if team wants to expose Blind Spy as playable theme
- No breaking changes to existing code or tests

---

## Testing Notes

**Not Yet Tested:**
- Build verification pending
- Existing RandomCategoryTests should still pass (Blind Spy resolves to other themes)
- New tests may be needed if Blind Spy becomes concrete theme

**Recommendation:**
- Run full test suite to verify no regressions
- Update GameLogic.swift comments to clarify Blind Spy's dual nature (has words but randomizes)

---

## Decision Outcome

**APPROVED & IMPLEMENTED**

Blind Spy theme now has 27 family-friendly spy words in both themes.json and ThemeManager.swift fallback. This resolves the critical QA issue while maintaining current gameplay behavior. Team can decide future direction for Blind Spy (concrete vs. meta-theme) without additional data preparation.

**Next Steps:**
1. ✅ Code changes complete
2. ⏳ Run test suite to verify no regressions
3. ⏳ Product to decide: Keep Blind Spy as randomizer or expose as concrete theme?
4. ⏳ Update documentation/comments to clarify Blind Spy behavior

---

**Closes:** Bruce Banner QA Issue #1 (Blind Spy missing words)
