# Stats Layout: Single-Line Horizontal Format

**Date:** 2024
**Agent:** Natasha (Frontend Developer)
**Status:** Implemented

## Context
The Remaining/Locked stats on the card reveal page (TurnIndicatorView) were taking up excessive vertical space. The original layout used VStack columns with 3 rows per stat (icon on top, number in middle, label below), creating a tall, bulky appearance.

## Decision
Converted stats to a compact single horizontal line format where each stat displays as `[icon] [number] [label]` in one HStack row.

## Implementation Details

### Layout Structure
- **Before:** Outer HStack → VStack per stat (3 rows each) → icon/number/label stacked vertically
- **After:** Outer HStack → Inner HStack per stat → icon/number/label side by side

### Typography
- Icon: 12pt regular (down from 13pt)
- Number: 12pt bold (down from 13pt)
- Label: 11pt medium (up from 10pt semibold)

### Spacing & Padding
- Inner HStack spacing: 4pt (tight grouping within each stat)
- Outer HStack spacing: 12pt (separation between stats)
- Vertical padding: 5pt (down from 6pt)
- Divider: Constrained to 14pt height to match single-line content

### Visual Result
Stats block transforms from a tall 3-row component to a slim, badge-like single line while maintaining:
- Color coding (green for Remaining, red for Locked)
- Numeric transitions and animations
- Accessibility labels and values
- Cross-platform compatibility (iOS/macOS)

## Rationale
- **Space Efficiency:** Reduces vertical footprint by ~60%
- **Scanability:** Single-line stats are faster to read
- **Modern UI:** Badge-like appearance feels more polished
- **Consistency:** Horizontal layouts are standard for compact stat displays

## Files Modified
- `/Users/amolbabu/projects/familyGame/ios/FamilyGame/FamilyGame/Views/TurnIndicatorView.swift` (lines 50-86)

## Future Considerations
- This pattern can be applied to other stats displays in the app
- Consider extracting as reusable `CompactStatView` component if pattern repeats
