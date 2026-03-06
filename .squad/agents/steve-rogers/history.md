# Steve Rogers — History

## Project Context

**Project:** familyGame  
**Tech Stack:** Swift, SwiftUI, likely GameKit or game physics libraries  
**Goal:** A fun, family-friendly game that all ages can enjoy  
**User:** Amolbabu  

---

## Core Context

Steve Rogers is the Lead Architect. You make scope decisions, approve architecture, and validate game design alignment.

---

## Learnings

### 2026-03-08 — Phase 2 Architecture Designed ✅
- **Status:** Architecture blueprint complete, ready for team execution (zero blockers)
- **Design Approach:** Turn-based state machine with immutable GameState + reactive SwiftUI UI
- **Key Decisions Finalized:**
  - **State Management:** GameScreenViewModel (@Observable) orchestrates game logic; UI reacts to screenState changes
  - **Animation:** SwiftUI native (`.rotation3DEffect` + `.withAnimation`) — no Combine pipelines needed
  - **Card Grid:** LazyVGrid with dynamic columns (2–4 cols based on playerCount) — responsive, family-friendly tap targets
  - **Error Handling:** Typed GameError enum + screenState.error case — specific user feedback (vs. generic errors)
  - **Replay:** In-place GameState reset (fast "Play Again") + "Return to Setup" fallback
  - **Accessibility:** VoiceOver labels per component + Dynamic Type support + haptic feedback
- **State Machine Design:** Exhaustive transitions validated (selectingCard → cardRevealing → cardRevealed → cardHiding → cardLocked → [gameOver | nextPlayerPrompt])
- **Module Structure:** GameScreenViewModel (Tony), GameScreenView + CardView + TurnIndicatorView + EndGameView (Natasha), comprehensive test coverage (Bruce)
- **Testing Strategy:** Unit + integration tests covering all state transitions, error cases, 2–8 player flows, accessibility, performance
- **Parallel Work Enabled:**
  - Natasha: GameScreenView layout + CardView components (2–3 days)
  - Tony: GameScreenViewModel logic + error handling (2–3 days)
  - Bruce: State machine + integration + accessibility tests (2–3 days)
- **Risk Mitigations:** LazyVGrid portrait-only (Phase 3 iPad), card animation optimization deferred, auto-hide timer invalidation pattern, touch target validation
- **Deliverable:** `.squad/decisions/inbox/steve-rogers-phase2-architecture.md` (4500+ words, 10 sections, complete design blueprint)

### 2026-03-07 — PRD Decomposition Complete ✅
- **Status:** Architecture validated, work sequence defined, 5 decision points identified
- **PRD Assessment:** Well-formed MVP scope, all 16 user stories have clear acceptance criteria
- **Key Decisions Made:**
  - **State Management:** SwiftUI + Combine MVVM (no Redux complexity needed for turn-based game)
  - **Data Layer:** Codable JSON for themes, immutable Game struct for state (value type, copy-on-write)
  - **Tech Stack:** SwiftUI (UI) + Combine (@Published) + Foundation (Codable) — no external dependencies needed
  - **Dependency Injection:** Light-touch DI via instance properties; no DI framework at MVP
  - **Testing Strategy:** XCTest for unit/integration tests; snapshot testing for UI
- **Architecture Patterns:**
  - Immutable game state (struct-based) enables time-travel debugging and testing
  - Turn validation via state machine guards (compile-time safety)
  - Theme randomization: deterministic seeding for tests, default randomness for gameplay
  - Error handling: JSON parsing failures fallback to bundled themes; card generation edge cases clamped
- **Work Sequence:**
  - Phase 1 (Foundation): 6 days → Welcome + Setup + Card Generation
  - Phase 2 (Core Game): 5 days → Turn-based UI + Game Flow + Validation
  - Phase 3 (Polish): 7 days → Animations + Accessibility + iPad Support
  - Critical path to playable MVP: ~11 days (2.5 weeks)
- **Decision Points (Require User Sign-Off):**
  1. End-game screen: Minimal vs. Rich (Recommend: Minimal "Game Over")
  2. Player names: Generic vs. Named input (Recommend: Generic "Player 1, 2, 3")
  3. Player count: 2–4 vs. 2–8 (Recommend: 2–8 for family flexibility)
  4. Content moderation: Manual vs. Flagged JSON (Recommend: Manual review MVP)
  5. Initial themes: Approved word lists (Places, Countries, Things — ~30 words each)
- **File Organization:** Modular Swift structure with Models, Views, ViewModels, Services, Resources
- **Risk Mitigation:** Identified 5 key risks (SwiftUI learning curve, JSON rigidity, older device performance, content curation, player count edge cases) with mitigations

### 2026-03-06 — PRD Review Session
- **Status:** Blocked on missing PRD document
- **Finding:** Task referenced 7 epics + 16 user stories, but no PRD found in repo
- **Action Taken:** Created comprehensive blocker document in .squad/decisions/inbox/
- **Prerequisites Identified:** 
  - Must have: Game overview, epic list, user stories with acceptance criteria
  - Turn flow mechanics and win conditions
  - Theme/card data structure and family-friendly guidelines
  - Platform and multiplayer requirements
- **Preliminary Architectural Stance:**
  - SwiftUI + Combine for state management (recommended)
  - Codable-based theme loading with JSON support
  - Turn-based state machine with immutable game state
  - Modular structure: Models → ViewModels → Views → Services
