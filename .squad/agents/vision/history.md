# Vision — History

## Project Context

**Project:** familyGame  
**Tech Stack:** Swift, SwiftUI  
**Goal:** Delightful, accessible, visually cohesive design  
**User:** Amolbabu  

---

## Core Context

Vision is the Design & UX Specialist. You create visual systems, design screens and interactions, and drive accessibility from a design lens.

---

## Learnings

- Family game color psychology: Use warm, energetic hues (coral, sunny yellow, mint) combined with pale backgrounds to evoke playfulness while anchoring UI with a deep accent for legibility. Favor pastels with bright accents for emotional warmth; apply >=4.5:1 contrast for body and CTA text (use Ocean #2D6A89 or Ink #0F172A for primary text). Provide an optional high-contrast toggle that increases saturation and darkens primary accents for low-vision users.

- SwiftUI responsive layout patterns for hero images: Prefer GeometryReader to compute hero height as a percentage of available space (e.g., min(proxy.size.height * 0.4, 360)). Use .resizable() + .scaledToFit() and constrain maxWidth to 90% of the safe area width; wrap in a rounded container with .background(Color.Surface) and .cornerRadius(20). Prefer VStack with flexible Spacer() between hero and CTAs so CTAs remain reachable at bottom on short devices.

- iOS safe area + Dynamic Type considerations: Always call .ignoresSafeArea(.container, edges: .all) for background colors but keep content inside SafeArea via .padding(.top, safeAreaInsets.top + 16). Use semantic fonts (.title, .headline, .callout) to respect Dynamic Type and avoid fixed font sizes for long-form text; use minHeight for buttons rather than fixed heights to allow vertical scaling while preserving tappable area.

- Launch page design decisions: Use a hero-first layout with a rounded hero card (20pt radius), hero height = min(36% of viewport height, 360pt), and centered title above a dominant Primary CTA. Provide both illustration and photographic hero options; prefer illustrations for privacy and consistent tone across locales.

- Image integration learnings: Prefer a 4:3 or 3:2 landscape aspect for hero assets, center-crop with focal point coordinates, and add a subtle bottom gradient (transparent→rgba(15,23,42,0.6)) when overlaying text to meet 4.5:1 contrast. Always supply @1x/@2x/@3x assets and accessible alt text or accessibilityLabel for meaningful images.

- Design tokens & implementation: Extract ThemeColors.swift and AppFonts.swift early. Tokenize spacing on an 8pt baseline (4/8/12/16/24/32/48), set button minHeight 48–52pt, and use semantic font scaling for Dynamic Type. Create PrimaryButton and SecondaryButton components to encapsulate states: default/hover/active/disabled/focus.

