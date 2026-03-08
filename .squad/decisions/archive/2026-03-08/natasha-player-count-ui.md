# Decision: Simplify setup to numeric player count (natasha-player-count-ui)

Date: 2026-03-08

Decision: For the MVP flow, the setup screen will collect only the number of players via a numeric input (1–12) instead of per-player name entry. The app will map that number to placeholder player names at game start.

Rationale:
- Simplifies onboarding for family play (faster to start)
- Reduces input friction on small devices
- Aligns with product decision to defer per-player customization to a later phase

Impacts:
- AppState continues to hold playerCount and playerNames; setPlayerCount will be used to generate placeholder names when the game starts.
- UI validation enforces 1–12 players and shows inline error messages when out of range.

Owner: Natasha (Frontend)

