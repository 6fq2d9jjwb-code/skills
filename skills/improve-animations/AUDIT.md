# Animation Audit Playbook

The eight audit categories, what to hunt for in each, and how to grade what you find. Every value you cite in a finding or a plan — a curve, a duration, a spring config, a threshold — comes from [STANDARDS.md](STANDARDS.md), the shared standards copied into this folder. Never approximate one from memory; copy it. Distilled from Emil Kowalski's design engineering philosophy ([emilkowal.ski](https://emilkowal.ski/)).

## 1. Purpose & frequency

Standard: **Should it animate?** (the frequency table and the purpose list).

Hunt for: animations on keyboard-initiated actions; command palettes with open/close transitions (Raycast has none, and that is correct); decorative motion on list items or hover states hit constantly; motion whose purpose can't be named in one of the six words. The strongest fix is often **delete the animation**.

## 2. Easing & duration

Standard: **Easing** (decision order, the three tokens) and **Duration** (the table, the 300ms rule and its two named exceptions: drawers/sheets, toasts).

Hunt for: `ease-in` anywhere; bare `ease` / `linear` on entrances; built-in `ease-out` on a deliberate animation; durations over 300ms on UI elements outside the named exceptions with no stated reason; tooltip delay plus animation on every tooltip in a toolbar (after the first, they should be instant).

## 3. Physicality & origin

Standard: **Physicality and origin**.

Hunt for: `scale(0)`; trigger-anchored elements (popovers, dropdowns, menus, tooltips) that only fade in; `transform-origin: center` or none on trigger-anchored elements; pressable elements with no press feedback. Do **not** report `transform-origin: center` on a modal, a pure fade on a backdrop or scrim, or a same-spot crossfade: those are correct.

## 4. Interruptibility

Standard: **Interruptibility**, **Springs**, **Asymmetric timing**, **Gestures and drag**.

Hunt for: `@keyframes` on toasts, toggles, or anything rapidly triggered; gesture handlers that tween with fixed-duration keyframes; drags dismissed by distance alone (velocity should count); hard stops at drag boundaries instead of rising friction; symmetric timing on a hold or press-and-release interaction; bounce on an element that arrived without momentum.

## 5. Performance

Standard: **Properties** and **Performance**.

Hunt for: `transition: all`; animated layout properties outside the sanctioned exceptions (`clip-path`; `height` on accordions; `width` on an absolutely positioned childless element); Motion `x` / `y` / `scale` shorthands on pages that are busy while the motion runs; `setProperty('--x', …)` on a parent driving child transforms; rAF loops doing what CSS or WAAPI could; transition-time blur over 20px.

## 6. Accessibility

Standard: **Reduced motion and pointer gating**.

Hunt for: movement with no `prefers-reduced-motion` handling; ungated `:hover` motion; reduced-motion implementations that remove all feedback instead of keeping the opacity and color changes that explain state.

## 7. Cohesion & tokens

Standard: **Cohesion**, **Stagger**, **Masking a crossfade that won't settle**.

Hunt for: duplicated near-identical easings and durations (a consolidation finding: they belong in shared tokens); one bouncy component in a crisp app; list or grid entrances with no stagger; crossfades that visibly double-expose.

## 8. Missed opportunities

The additive category — places that don't animate but should:

- State changes that teleport (content swaps, layout jumps) where a brief transition would prevent a jarring change.
- Spatially-connected UI (a panel that appears from a trigger) with no motion explaining where it came from.
- Rare, high-emotion moments (first-run, success, celebration) rendered with none of the delight budget they're allowed.
- `translate` percentages, `clip-path: inset()` reveals, and a same-document view transition as the tools for these — no hardcoded pixel offsets.

Report at most a handful, grounded in actual UX seams you observed — not a wishlist.

## Severity

- **HIGH** — feel-breaking: wrong easing on UI, animation on keyboard or high-frequency actions, dropped frames, `scale(0)`.
- **MEDIUM** — noticeably off: wrong origin, non-interruptible dynamic UI, missing reduced-motion handling.
- **LOW** — polish: stagger, blur-masked crossfades, token consolidation.

Order findings by leverage (impact ÷ effort), not by category.
