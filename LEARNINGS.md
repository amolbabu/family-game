# Project Learnings — SPY WORD iOS App

## Architecture

### Safe Area / Full Screen

- `UIHostingController` does NOT respect SwiftUI's `.ignoresSafeArea()` on its own for the status bar area on iPhone 15+
- **Solution**: Create `EarlyWindowConfigurator` (UIKit) that sets `safeAreaRegions = []` on the hosting controller
- Screens read `UIApplication.shared.connectedScenes → UIWindowScene → window.safeAreaInsets.top` in `.onAppear` via UIKit bridge
- **Hardcoded 72pt fallback** exists if UIKit read fails (LOW priority tech debt — replace with `GeometryReader` in future sprint)

### Emoji Rendering

- If a `.custom("FontName")` font call references a font NOT included in the Xcode bundle target, iOS falls back and **breaks emoji rendering** — emojis show as "?" boxes
- **Fix**: Replace all `.custom("Baloo2-Bold")` / `.custom("Baloo2-Medium")` with `.system(size: X, weight: .bold/.medium, design: .rounded)`
- The `.rounded` design closely matches Baloo2's visual style
- **Files affected**:
  - AnimatedTitle.swift
  - WelcomeScreenView.swift
  - VibrantButton.swift
  - HowToPlayView.swift
  - PrivacyPolicyView.swift

### Audio

- `LaunchSoundManager` uses synchronous audio API (compiler warning, LOW priority)
- Welcome screen background chime was removed per user request — **do not re-add**

## UI Patterns

### Stats/Counter Display (Card Reveal Page)

- **Final settled pattern**: Single-line HStack — `[icon] [number] [label]` all on one row
- **Font sizes**:
  - Icon: 12pt system rounded, bold
  - Number: 12pt system rounded, bold
  - Label: 11pt system rounded, medium
- **Layout rules**:
  - No `Spacer()` at end of HStack (causes left-alignment imbalance)
  - Divider between stats: `.frame(height: 14)`
  - Padding: `.padding(.horizontal, 12).padding(.vertical, 5)`
- **⚠️ LOCKED**: Do not change stats sizing without Bruce QA sign-off

### Theme Grid

- 6 themes displayed in 3 rows × 2 columns
- **Row 1**: Place, Country
- **Row 2**: Things, Jobs
- **Row 3**: Animal, Blind Spy
- "Random" was renamed to "Blind Spy"

### Font System

- **Always use** `.system(size:weight:design:)` with `design: .rounded` for app-wide font consistency
- **Never use** `.custom()` unless the font file is verified in the Xcode target bundle
- After any font changes, test emoji rendering to ensure no "?" boxes appear

## Game Logic

### Player Minimum

- Minimum **3 players required** (changed from 2)
- Enforced in player setup validation

### Themes / Categories

- 6 themes total: Place, Country, Things, Jobs, Animal, Blind Spy
- **Animal theme**: 20+ animal words added in recent sprint
- **Known gap**: "Things" theme has fewer words than other categories (not yet addressed)

## Git / Branch Policy

- **`main`** — Active development, all new commits go here
- **`release/1.0.0`** — Frozen App Store snapshot, DO NOT commit to this branch
- Scribe commits `.squad/` state changes to main after each session

## Team Process Learnings

### QA Gate is Essential
- Bruce must test in simulator before UI is considered done
- Static code review alone is insufficient for UI changes

### Specification Precision Matters
- "Make it smaller" without a specific size leads to over-correction
- Always specify exact pt sizes when requesting UI adjustments
- Lock UI decisions in `.squad/decisions.md` to prevent regression

### Font Changes Affect Emoji Rendering
- Always test emoji display after any font changes
- Custom fonts can silently break if bundle targets are misconfigured

### Communication & Iteration
- Stats sizing went through 5 iterations — could have been prevented with:
  - Early simulator testing by Natasha
  - QA gate enforced from the start
  - Specific size targets agreed upfront
- **Lesson**: Get consensus on exact measurements before implementation

---

## Next Steps (Future Sprints)

- [ ] Replace 72pt safe area hardcode with `GeometryReader` approach
- [ ] Add more words to "Things" theme category
- [ ] Convert `LaunchSoundManager` to async audio API
- [ ] Consider expanding game modes (e.g., difficulty levels)
