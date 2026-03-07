# Vision — Reusable Design Patterns & Tokens

This file captures reusable tokens and patterns discovered while designing the launch page.

Spacing scale (8pt baseline)
- xs: 4pt
- sm: 8pt
- md: 16pt
- lg: 24pt
- xl: 32pt
- xxl: 48pt

Corner radius scale
- small: 8pt
- medium: 12pt
- large: 20pt

Shadows
- subtle: radius 8pt, y: 4pt, color: rgba(15,23,42,0.06)
- elevated: radius 12pt, y: 6pt, color: rgba(15,23,42,0.08)

Button tokens
- PrimaryButton: minHeight 52pt, radius 14pt, font 17pt semibold, padding 20pt horizontal
- SecondaryButton: minHeight 48pt, 1px border, radius 12pt, font 16pt medium

Typography tokens
- H1: 28pt semibold (system rounded preferred)
- H2: 18pt semibold
- Body: 17pt regular
- Caption: 13–14pt

Usage notes
- Centralize these tokens into ThemeSpacing.swift, ThemeColors.swift, and AppFonts.swift to keep UI consistent and make future theming trivial.

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
