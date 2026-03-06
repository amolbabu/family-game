### 2026-03-06T15:27:26Z: PRD Decision Points — Autonomous Decisions

**By:** amolbabu (via autonomous coordinator decision)  
**Context:** Steve Rogers identified 5 blocking decision points for Phase 1 launch. User unavailable for immediate feedback. Coordinator made conservative MVP-aligned decisions.

---

## Decision 1: End-game Experience
**Choice:** Just show discussion prompt (no built-in voting or auto-reveal)  
**Rationale:** MVP simplicity. Families naturally discuss around a single phone. Voting/reveal logic can be added post-launch (Epic 7: Future extensibility).  
**Implementation:** After all cards are viewed, show: "All cards revealed! Did everyone guess correctly? Discuss and decide together."

---

## Decision 2: Player Names
**Choice:** Players enter names before game starts  
**Rationale:** Adds personalization and clarity during turns ("It's Sarah's turn"), makes the game more engaging for families. Minimal added complexity.  
**Implementation:** Setup screen → "Player Names" section with text fields (Player 1, Player 2, ... Player N) with defaults pre-filled.

---

## Decision 3: Player Count Range
**Choice:** 2–8 players (recommended range)  
**Rationale:** 2 = minimum for a spy game. 8 = practical limit for a single phone (screen space, turn flow). Aligns with family group size.  
**Implementation:** Segmented control or picker: 2, 3, 4, 5, 6, 7, 8 options.

---

## Decision 4: Initial Theme Words
**Choice:** Proceeding with MVP word lists (to be finalized by team)  
**Rationale:** PRD allows agents to generate initial content. Tony Stark (Backend) will create themes.json with curated family-friendly words.  
**Scope:**  
- **Place:** Paris, London, Tokyo, Cairo, Sydney, Rome, Dubai, Barcelona  
- **Country:** France, Italy, Japan, Brazil, Australia, Canada, Spain, Thailand  
- **Things:** Bicycle, Book, Camera, Clock, Elephant, Guitar, Hat, Lighthouse  
**Note:** User can refine these during Phase 1 if new words are preferred.

---

## Decision 5: iPad vs. iPhone
**Choice:** iPhone portrait-only for MVP; iPad support deferred to Phase 3 (Polish)  
**Rationale:** Phase 1 ships on iPhone (highest urgency). iPad landscape layout adds complexity for MVP. Phase 3 explicitly includes "iPad layout" as scope.  
**Implementation:** Lock to portrait orientation in Info.plist. Test on iPhone 14/15 Pro / Max.

---

## Phase 1 Launch — UNBLOCKED ✅
All decisions finalized. Team can begin parallel work immediately:
- **Natasha Romanoff** (Frontend): Welcome screen + setup flow  
- **Tony Stark** (Backend): GameState model + themes.json + randomization logic  
- **Bruce Banner** (QA): Write test cases for card generation, turn flow  
