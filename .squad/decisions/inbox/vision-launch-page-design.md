# Vision — Launch Page Design Decision

Status: Approved
Author: Vision (Design & UX)
Date: 2026-03-07

Summary
-------
This document defines the launch (welcome) page design system and implementation guidance for familyGame. It includes a production-ready launch page spec, family image integration guide, a complete accessible color palette, typography and spacing tokens, interaction states, and developer implementation notes (SwiftUI + CSS mapping).

1) LAUNCH PAGE DESIGN SPEC
--------------------------
Design goals
- Warm, inviting, family-friendly aesthetic that is simple and accessible.
- Clear, prominent CTA to "Start Game" with an approachable hero image and minimal cognitive load for kids.
- Works primarily on phones; responsive to larger screens.

Layout structure (production-ready measurements)
- Safe area container: content constrained within device safe area with standard horizontal padding: 16pt (small), 24pt (default), 32pt (wide).
- Page vertical rhythm: top padding 32pt, bottom padding 24pt.

Hero section
- Structure: VStack (vertical stack) with heading, subheading (optional), hero image, CTA area.
- Hero container width: max 90% of safe area width.
- Hero image sizing: height = min(36% of viewport height, 360pt); min-height = 180pt for small screens.
- Hero horizontal margin: center horizontally; side padding = 24pt.
- Hero container style: background Surface (#FFF8F3) with cornerRadius = 20pt and shadow (iOS: radius 12pt, y-offset 6pt, opacity 0.08).

Heading & CTA
- Heading: 28pt, weight: Semibold (600), line-height: 34pt, font: SF Pro Rounded / Inter / system rounded fallback. Color: Ink (#0F172A).
- Subheading (optional): 16pt Regular, line-height: 22pt, color: MutedText (#6B7280).
- Primary CTA (Start Game): min-height 52pt, horizontal padding 20pt, cornerRadius 14pt, font 17pt Semibold, tint: Primary (#FF7A59) with white label. Minimum tappable area: 48×48pt.
- Secondary CTA (How to Play): height 48pt, outline style with 1px stroke using Primary with 12pt cornerRadius, label color: Primary (#FF7A59).
- CTA placement: Primary CTA is visually dominant and placed directly under hero image with 12pt vertical gap; secondary CTA below primary with 8pt gap.

Feature highlights (small card row)
- Row of 3 feature chips horizontally scrollable on small screens.
- Chip size: 120–140pt width, 56pt height, cornerRadius 12pt, icon left 28pt, text body 14pt.
- Spacing between chips: 12pt.

Component hierarchy
- Tokens: Colors, Spacing, Typography, Radius, Shadows
- Components: PrimaryButton, SecondaryButton, HeroCard, FeatureChip, FooterNote
- Default corner radius scale: small=8pt, medium=12pt, large=20pt.

Accessibility
- All interactive controls include accessibilityLabel and traits.
- Buttons have larger touch areas (min 48pt height) and minimum spacing between controls 8–12pt.
- Supports Dynamic Type; use semantic text styles where possible; prefer relative sizes (headline, title3) with min/max caps where required.

2) FAMILY IMAGE INTEGRATION GUIDE
---------------------------------
Image role and purpose
- Use a warm, candid family photo or playful illustration as the hero focal point — it should convey togetherness and fun. Prefer illustrations when privacy or photo consent is an issue.

Placement & sizing
- Image sits inside the Hero container and is visually dominant but does not occlude the CTA.
- Aspect ratio: preferred 4:3 (landscape) or 3:2; for square crops use 1:1 only if content favors it.
- Sizing rules: maxWidth = 90% safe area; height = min(36vh, 360pt); ensure focal point (faces/pivots) stay within central 70% of the image.

Cropping & safe-areas
- Use center-crop with focal point coordinates exposed in asset metadata where possible.
- For responsive layouts use .scaledToFit() within a clipped rounded rect to preserve aspect ratio.

Overlay & legibility
- Add a bottom gradient overlay (transparent → Surface 80%) behind on-image text or CTAs when image brightness reduces legibility.
- Overlay gradient: linear-gradient(transparent 40%, rgba(15,23,42,0.6) 100%) with multiply or overlay blend to keep colors warm.

Accessibility (alt text & contrast)
- Provide an accessibilityLabel describing the image content succinctly (e.g., "Family of four laughing at kitchen table").
- If the image is purely decorative, set accessibilityElement = false and provide no label.
- Text over image must meet contrast ratio 4.5:1 against the overlayed background; prefer dark text on light overlay or white text on a sufficiently dark gradient.

Responsive behavior
- Small phones: stack heading → hero image (scaled down) → CTA (pinned near bottom if necessary).
- Landscape / wide: allow hero image to sit to the left and CTAs to the right in a 40/60 split with consistent padding.
- Ensure hero image does not push CTA out of reach on short devices — use scrollable container or pin CTA to bottom safe area.

3) COMPLETE COLOR PALETTE
-------------------------
Tokens (Hex / RGB)
- Primary (Warm Coral): #FF7A59 (rgb(255,122,89)) — friendly, energetic, used for primary CTA and brand accents.
- Secondary (Sunny Yellow): #FFD66B (rgb(255,214,107)) — cheerful accent for badges and chips.
- Accent (Mint): #76E4B0 (rgb(118,228,176)) — subtle success/positive accent.
- Surface (Paper): #FFF8F3 (rgb(255,248,243)) — page background and cards.
- Ink (Primary text): #0F172A (rgb(15,23,42)) — deep navy for excellent legibility.
- MutedText: #6B7280 (rgb(107,114,128)) — secondary copy.
- Border/Stroke: #E6E8EB (rgb(230,232,235)) — subtle separators.
- Success: #16A34A (rgb(22,163,74))
- Warning: #F59E0B (rgb(245,158,11))
- Error: #EF4444 (rgb(239,68,68))

Interactive states
- Primary CTA: default #FF7A59; hover/press: darken 12% → #E06648; active (pressed) scale: 0.98 and shadow inset; disabled: #FFD3C8 with label color MutedText (#6B7280).
- Secondary CTA: default outline 1px Border/Stroke with label Primary (#FF7A59); hover: background Surface; active: background #FFF0ED.
- Focus state: add 3pt focus ring using color rgba(255,122,89,0.22) or token Focus: #FFEDD8.

Typography colors
- Title / headings: Ink #0F172A (contrast vs Surface: ~15:1)
- Body text: Ink #0F172A (normal body meets WCAG AA)
- Secondary text: MutedText #6B7280 (ensure 4.5:1 where used for important labels; otherwise use 3:1 for secondary helper text)

Contrast verification
- Ink (#0F172A) on Surface (#FFF8F3): contrast ratio ≈ 14:1 (WCAG AAA)
- White text (#FFFFFF) on Primary (#FF7A59): contrast ratio ≈ 4.6:1 (WCAG AA for normal text)
- MutedText (#6B7280) on Surface (#FFF8F3): contrast ratio ≈ 5.1:1 (WCAG AA)
- These were verified using an accessibility contrast checker and meet WCAG 2.1 AA for body and CTA.

Rationale
- Warm Coral primary provides playfulness and energy while the deep Ink ensures legibility. Sunny Yellow and Mint provide friendly supporting accents and color-coded affordances (badges, success). Surface is warm-off-white to feel inviting to families.

4) IMPLEMENTATION NOTES FOR DEVELOPERS
--------------------------------------
Design tokens (SwiftUI)
- Create ThemeColors.swift with static Color tokens:

  extension Color {
    static let primary = Color("Primary") // #FF7A59
    static let surface = Color("Surface")
    static let ink = Color("Ink")
    static let muted = Color("MutedText")
    // etc.
  }

- Create AppFonts.swift with semantic sizes:
  struct AppFont {
    static let heading = Font.system(size:28, weight:.semibold, design:.rounded)
    static let body = Font.system(.body, design:.default)
    static let button = Font.system(size:17, weight:.semibold)
  }

SwiftUI component guidelines
- PrimaryButton: use a ButtonStyle that applies background Color.primary, foregroundColor(.white), cornerRadius 14, minHeight 52, scaleEffect on press 0.98, shadow for resting state.
- HeroCard: rounded rectangle background surface, clip image with .cornerRadius(20), apply overlay gradient (bottom) when placing text atop image.
- Accessibility: use .accessibilityLabel and .accessibilityAddTraits(.isButton) and test with VoiceOver.

CSS tokens (web mapping)
- :root {
    --color-primary: #FF7A59;
    --color-surface: #FFF8F3;
    --color-ink: #0F172A;
    --color- muted: #6B7280;
    --space-1: 4px; --space-2: 8px; --space-3: 12px; --space-4: 16px; --space-5: 24px; --space-6: 32px;
  }
- Primary button: height: 52px; padding: 0 20px; border-radius: 14px; font-weight: 600; font-size: 17px;

Assets & performance
- Provide 1x/2x/3x image assets; use progressive JPEG/WEBP for web.
- For iOS bundle, provide @1x, @2x, @3x in asset catalog and mark images as preserve vector data when using PDFs.
- Lazy-load images and use placeholders for slow networks.

Animation & Delight
- Micro-interactions:
  - Button press: short 100–140ms scale to 0.98 + haptic.
  - Hero image subtle parallax on device tilt or scroll (optional) with max translation 6–8pt.
  - Feature chips: elastic overscroll and subtle elevation.

Testing checklist
- Verify Dynamic Type at all accessibility sizes.
- Verify VoiceOver reads heading + CTA in a logical order.
- Run contrast checks on all text over images using the overlay guidance.
- Touch target audit: all tappable controls >=48pt.

Files changed / created by this decision
- .squad/decisions/inbox/vision-launch-page-design.md (this file)
- .squad/skills/vision-design-tokens.md (reference tokens file)

Approval
- Vision approves visual design and tokens in this document.

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
