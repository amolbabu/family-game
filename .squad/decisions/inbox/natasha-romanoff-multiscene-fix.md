### 2026-04-09: Root cause fix — Auto-generated Info.plist override
**By:** Natasha Romanoff (UI)
**What:** Disabled GENERATE_INFOPLIST_FILE and set UIApplicationSupportsMultipleScenes to false
**Why:** Xcode was auto-generating Info.plist during build, ignoring our custom settings. This allowed iOS 18+ to apply multitasking window constraints on iPhone, causing ~240px black bars on iPhone 17+
**Files:** 
- ios/FamilyGame/FamilyGame.xcodeproj/project.pbxproj (GENERATE_INFOPLIST_FILE = NO)
- ios/FamilyGame/FamilyGame/Info.plist (UIApplicationSupportsMultipleScenes: false)
**Verified:** iPhone 17 Pro simulator — perfect full screen, no letterboxing
**Status:** Fixed and committed (commit ce4478f5)
**Key Learning:** Always verify Xcode build settings aren't overriding Info.plist changes
