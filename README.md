# SPY WORD

A fun iOS SwiftUI family party game where players collaborate to guess a secret word—but one player, the "Blind Spy," must figure out what everyone is talking about without being told directly.

## How the Game Works

- All players get cards displaying a theme word (e.g., "Tiger" in the Animal category)
- One player is randomly selected as the "Blind Spy" and does NOT see the word
- All other players give cryptic clues about the word
- The Blind Spy tries to guess the word before being discovered
- If the Blind Spy guesses correctly, they win—otherwise, the word is revealed

## Team

| Role | Name |
|------|------|
| Frontend Dev (UI/SwiftUI) | Natasha |
| QA Engineer (Testing, Simulator) | Bruce Banner |
| Session Logger / Scribe | Scribe |
| Work Monitor | Ralph |

## 🔄 Sprint Retrospective Summary

### ✅ What Went Well

- **Full screen support fixed** for iPhone 15+ (safe area via UIKit bridge, `EarlyWindowConfigurator`)
- **Emoji rendering fixed** — replaced missing Baloo2 custom fonts with `.system(size:weight:design:.rounded)` across 5 files; emojis now render correctly
- **New "Animal" theme category** added with 20+ words
- **"Random" renamed to "Blind Spy"** throughout the app for clearer branding
- **Welcome screen background sound removed** (per user feedback)
- **Theme grid reorganized** into 3 rows: Row 1 = Place/Country, Row 2 = Things/Jobs, Row 3 = Animal/Blind Spy
- **Minimum player count enforced at 3** (was 2)
- **Branch discipline enforced**: all new work goes to `main`, `release/1.0.0` frozen as App Store snapshot
- **Stats layout perfected** on card reveal page — compact single-line layout (Bruce QA approved)
- **QA gate introduced**: Bruce now reviews UI before changes ship

### ❌ What Went Wrong

- **Stats ping-pong**: Remaining/Locked stats went through 5 iterations (too large → 11pt/8pt → 9pt/6pt → 10pt inline unreadable → 13pt/10pt tall → 12pt/11pt compact ✅)
  - Root cause: Natasha shipped without testing in simulator, no QA gate in place early enough
- **Bruce not testing**: Multiple calls for Bruce to run simulator tests before approving UI (was doing static code review only)
- **Wrong branch**: Changes initially pushed to `release/1.0.0` instead of `main`
- **Emoji bug shipped**: Baloo2 font files missing from bundle but custom font calls remained, causing emojis to render as "?"
- **Natasha over-corrected**: When asked to "make stats smaller," went to 6pt labels without considering readability minimum

### 📋 Action Items

- [ ] Bruce must run simulator test on every UI change before it's considered done
- [ ] Stats sizing is **LOCKED** at 12pt icon/number, 11pt label, single-line HStack — no changes without team discussion
- [ ] All commits and pushes go to `main` only — `release/1.0.0` is frozen
- [ ] Natasha must preview UI changes in Xcode canvas or simulator before submitting
- [ ] Font decisions: always use `.system(size:weight:design:.rounded)` — never add custom font files without verifying bundle target
- [ ] Hardcoded 72pt safe area fallback (LOW priority) — replace with `GeometryReader` in future sprint

## How to Build

```bash
# Open the Xcode project
open ios/FamilyGame/FamilyGame.xcodeproj

# In Xcode:
# 1. Select target: iPhone 15 Pro Max simulator (or later)
# 2. Product → Build
# 3. Product → Run
```

## Project Structure

```
ios/FamilyGame/
├── FamilyGame/
│   ├── Views/
│   ├── Models/
│   ├── Managers/
│   └── ...
├── FamilyGameTests/
└── FamilyGame.xcodeproj
```

## Git Workflow

- **`main`** — Active development, all new commits go here
- **`release/1.0.0`** — Frozen App Store snapshot, DO NOT commit to this branch

---

For technical architecture details, see [LEARNINGS.md](./LEARNINGS.md).
