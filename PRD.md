# Family Spy Game — Product Requirements Document

## Product Idea Summary

This is a family spy game mobile app where:

- The app opens with a welcome screen
- Players select:
  - Number of players
  - Theme
- One hidden SPY card is randomly assigned
- All other cards show the same word from the selected theme
- Players take turns privately viewing one card on the same phone
- After viewing, the card is flipped back and cannot be opened again

---

## Suggested Epics

1. Launch and home screen
2. Game setup
3. Theme management
4. Card generation and randomization
5. Turn-based card reveal
6. Game rules and usability
7. Future extensibility

---

## User Stories

### Epic 1: Launch and home screen

#### User Story 1
**As a player, I want to see a welcome screen when the app launches so that the game feels friendly and engaging.**

**Acceptance Criteria**
- When the app opens, a banner is displayed with the text "Family Game"
- A family image is shown on the launch screen
- A clear button such as Start Game is displayed
- Tapping Start Game moves the user to the setup screen

---

### Epic 2: Game setup

#### User Story 2
**As a player, I want to choose the number of players so that the game creates the correct number of cards.**

**Acceptance Criteria**
- The user can select the number of players before starting the game
- Minimum player count is defined by the app
- The app creates the same number of cards as the selected number of players
- The user cannot continue without selecting the number of players

#### User Story 3
**As a player, I want to choose a theme so that the game words match the selected category.**

**Acceptance Criteria**
- The setup screen displays available themes
- Initial themes are:
  - Place
  - Country
  - Things
- The user cannot start the game without selecting a theme
- After selecting a theme, the user can proceed to generate cards

---

### Epic 3: Theme management

#### User Story 4
**As an admin or developer, I want themes and words to come from a JSON file so that new themes and words can be added easily later.**

**Acceptance Criteria**
- Themes are read from a JSON file
- Each theme contains a list of words
- The initial JSON includes Place, Country, and Things
- New themes can be added without changing core game logic
- If a theme has no words, the app prevents game start and shows an error message

#### User Story 5
**As a family player, I want country names and other theme words to be simple and well-known so that kids can also play easily.**

**Acceptance Criteria**
- The Country theme uses famous country names
- Words are easy to understand for children
- Words selected for gameplay are family-friendly
- Difficult or obscure words are avoided

---

### Epic 4: Card generation and randomization

#### User Story 6
**As a player, I want one random card to be assigned as SPY and all other cards to show the same word so that the game works correctly.**

**Acceptance Criteria**
- For a selected player count of N, the app generates N cards
- Exactly one card contains SPY!
- All remaining cards contain the same selected theme word
- The position of the SPY! card is random for every game

#### User Story 7
**As a player, I want the game word to be randomly selected from the chosen theme so that each game feels different.**

**Acceptance Criteria**
- A word is randomly chosen from the selected theme
- The same word is shown on all non-spy cards
- The app supports replay with a newly randomized word
- Random selection should not always repeat the same word when enough words exist

---

### Epic 5: Turn-based card reveal

#### User Story 8
**As a player, I want all cards to initially appear face down so that no one can see the hidden words before their turn.**

**Acceptance Criteria**
- All cards are displayed face down at the beginning of the game
- Card content is hidden until a player taps a card
- No card content is visible before selection

#### User Story 9
**As the current player, I want to tap one available card to reveal its content privately so that I can know whether I am the spy or not.**

**Acceptance Criteria**
- A player can tap only one unrevealed card during their turn
- On first tap, the selected card reveals either:
  - The common theme word, or
  - SPY!
- Only the tapped card is revealed
- Already completed cards cannot be selected again

#### User Story 10
**As the current player, I want to tap the revealed card again to hide it so that the next player cannot see my card.**

**Acceptance Criteria**
- After viewing the card, the player can tap the same card again
- On second tap, the card flips back to its hidden side
- Once flipped back, that card becomes locked
- Locked cards cannot be opened again

#### User Story 11
**As the next player, I want to choose from only the remaining unopened cards so that every player gets a unique card.**

**Acceptance Criteria**
- After one player finishes, only remaining unlocked cards stay available
- The next player can select any one of the remaining cards
- A card already used by a previous player cannot be reopened
- The number of available cards decreases by one after each turn

---

### Epic 6: Game flow and usability

#### User Story 12
**As a family player, I want the app to guide players turn by turn so that the game is easy to play on a single phone.**

**Acceptance Criteria**
- The screen clearly indicates when it is a player's turn
- The app tells the current player to choose a card
- After a player finishes, the app prompts them to pass the phone to the next player
- The flow continues until all cards are used

#### User Story 13
**As a player, I want the game to know when all cards have been viewed so that the card selection phase ends properly.**

**Acceptance Criteria**
- The app tracks how many cards have been completed
- Once all cards are used, no further card selection is allowed
- The app shows a message that the reveal phase is complete
- The app can then move to a result or discussion screen if needed

#### User Story 14
**As a player, I want a simple and child-friendly design so that all family members can play comfortably.**

**Acceptance Criteria**
- Buttons and text are easy to read
- Navigation is simple
- The card interaction is visually clear
- The layout works well on a mobile screen

---

### Epic 7: Future extensibility

#### User Story 15
**As a product owner, I want to add more themes in the future so that the game remains fresh and replayable.**

**Acceptance Criteria**
- Theme list is dynamically loaded from JSON
- A newly added theme appears automatically in the app
- No code change is needed in the card flow when adding a new theme
- The same game rules work for all themes

#### User Story 16
**As a product owner, I want replay support so that players can start a new game quickly.**

**Acceptance Criteria**
- After a game ends, the app provides a Play Again option
- Starting a new game resets all cards and state
- A new random spy position is generated
- A new random word can be selected from the chosen theme
