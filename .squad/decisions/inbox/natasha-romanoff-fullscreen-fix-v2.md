### 2026-04-09: UIRequiresFullScreen fix (v2)
**By:** Natasha Romanoff (UI)
**What:** Added UIRequiresFullScreen true to Info.plist
**Why:** UILaunchScreen alone insufficient on iOS 18+; missing key causes OS to apply multitasking window sizing constraints
**Files:** ios/FamilyGame/FamilyGame/Info.plist
**Verified:** Screenshot on iPhone 17 Pro simulator — no black bars
**Status:** Fixed and committed
