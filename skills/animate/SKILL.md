---
name: animate
description: Build an animation from scratch, making the decisions in the order that determines whether it feels right — should it animate at all, what purpose, which tool, which properties, which curve and duration, how it interrupts, how it exits. Writes the implementation. Use when asked to animate something, add motion, make a component feel alive, or build a transition. For critiquing existing motion use review-animations; for auditing a whole codebase use improve-animations.
---

# Building Animations

A construction skill. It does ONE thing: turn a request for motion into an implementation that would survive a strict review. It does not audit a codebase (that's `improve-animations`), critique a diff (that's `review-animations`), hunt for places that could animate (that's `find-animation-opportunities`), or build for React Native (`animate-expo` covers that where it is installed).

The tables below are included from the shared standards. The full catalog, with springs, gestures, clip-path, performance, accessibility and debugging, is [STANDARDS.md](STANDARDS.md); load it when a step needs a value that isn't inlined here.

## Operating Posture

You are a senior design engineer building the animation yourself. The bar is Emil Kowalski's animation philosophy — the same bar `review-animations` enforces. Write it so it passes that review the first time.

Two failure modes, and the first is worse:

1. **Animating something that shouldn't animate.** The gate below exists to produce zero lines of code sometimes. That's a success, not a dodge.
2. **Animating the right thing with the wrong ingredients** — `ease-in` on an entrance, `scale(0)`, keyframes on a toast, a duration that makes a dropdown feel sluggish.

Never present motion options as a menu. Make the call, state the reasoning in one line, write the code.

## Hard Rules

1. **Run the sequence in order.** Steps 1 and 2 gate everything. Don't reach for a curve before you know whether it animates at all.
2. **No approximated values.** Every curve, duration, and spring config comes from the tables below or from [STANDARDS.md](STANDARDS.md). Never invent `cubic-bezier(0.4, 0, 0.2, 1)` because it looks familiar.
3. **Extend the codebase's tokens, don't fork them.** If `--ease-out` or a duration scale already exists, use it. Adding a parallel system is a defect.
4. **Reduced motion and hover gating ship with the animation**, not as a follow-up.
5. **Cheapest tool that works.** Don't install a motion library for a fade.

## The Build Sequence

### 1. Should this animate at all?

<!-- include: frequency -->
| Frequency | Decision |
| --- | --- |
| 100+ times/day (keyboard shortcuts, command palette toggle, tab switches) | **No animation. Ever.** Stop here. |
| Tens of times/day (hover effects, list navigation, row selection) | Near-imperceptible only: fast and subtle, or nothing |
| Occasional (modals, drawers, toasts, settings) | Standard animation |
| Rare / first-time (onboarding, success, celebration) | The delight budget lives here |

**Keyboard-initiated actions are a disqualifier, not a judgment call.** They repeat hundreds of times a day; animation makes them feel slow, delayed, and disconnected. Raycast has no open/close animation, and that is the optimal experience.
<!-- /include: frequency -->

If the request fails this gate, say so plainly and don't write the animation. Offer the non-motion alternative (instant state change, a static affordance) instead.

### 2. What is the purpose?

<!-- include: purpose -->
Every animation must answer "why does this animate?" with one of these words:

- **Feedback** — confirming the interface heard the user (press scale, hold-to-confirm fill)
- **Spatial consistency** — showing where something came from or went (a toast enters and exits the same edge; a panel grows from its trigger)
- **State indication** — making a state change legible (morphing button, expanding accordion)
- **Preventing a jarring change** — bridging content that would otherwise teleport
- **Explanation** — demonstrating how something works (marketing and onboarding only)
- **Delight** — allowed *only* at the rare / first-time frequency tier

"It looks cool" is not on the list. Also check **function**: data the user is reading or acting on should not move for style. A decorative mouse-tracking effect belongs on a marketing page, not on a graph in a banking app.
<!-- /include: purpose -->

Can't name it? Don't build it.

### 3. Pick the tool

<!-- include: tools -->
Walk down; stop at the first that fits.

| Need | Tool |
| --- | --- |
| Hover, press, color, a state toggle you control with a class or attribute | **CSS transition** |
| Entry animation on mount, no JS state | **CSS `@starting-style`** |
| Predetermined motion that must stay smooth while the page is busy | **CSS animation** (compositor-driven when it animates `transform` / `opacity`) |
| Motion tied to scroll position (progress, reveal, parallax) | **CSS scroll-driven animation** (`animation-timeline: scroll()` / `view()`), off the main thread |
| Two DOM states the browser should morph between (a list reorder, a route change, a card expanding into a page) | **View Transitions API** (`document.startViewTransition`, `view-transition-name`) |
| Programmatic control with CSS performance, no library | **WAAPI** (`element.animate()`) |
| A spring feel with no JS at all | **CSS `linear()` easing** holding a sampled spring curve (see Springs) |
| Springs driven by gestures, layout animations, exit animations, interruptible values | **Motion** ([motion.dev](https://motion.dev); React import `motion/react`) |

If the task needs a *component* rather than an animation (a toast, a drawer, a command menu, a dropdown), pick a maintained library instead of hand-rolling one; the `pick-ui-library` skill does that when it is installed, otherwise choose one yourself and say why. A `<div>` dropdown with no focus management is how hand-rolling ends.
<!-- /include: tools -->

### 4. Pick the properties

<!-- include: properties -->
- **`transform` and `opacity` only.** They skip layout and paint and run on the compositor. `width` / `height` / `margin` / `padding` / `top` / `left` trigger all three stages.
- **Sanctioned exceptions:** `clip-path` (reveals, hold-to-confirm, tab indicators); `height` for accordions, where there is no transform equivalent (keep it short); `width` on an absolutely positioned element with no children (a tab pill, a progress fill), because nothing else re-lays-out.
- **Percentages in `translate()`** are relative to the element's own size: `translateY(100%)` moves it by its own height whatever the content. Prefer them over hardcoded pixels.
- **In Motion, animate the full `transform` string** when the page may be busy. The `x` / `y` / `scale` shorthands are composed in JS every frame and drop frames under load; `transform: "translateX(100px)"` is hardware accelerated.
- **Never drive a child's transform from a CSS variable on the parent.** It recalculates styles for every child. Set `transform` on the element directly.
<!-- /include: properties -->

- **Never `scale(0)`.** Start from `scale(0.9–0.97)` + `opacity: 0`. Nothing in the real world appears from nothing.
- **`transform-origin` at the trigger** for popovers, dropdowns, menus, tooltips — `var(--transform-origin)` in Base UI. **Modals are exempt**; they're not anchored to a trigger, so they stay centered.

### 5. Easing and duration, or a spring

<!-- include: easing -->
| Situation | Easing |
| --- | --- |
| Entering or exiting | `ease-out` |
| Moving / morphing on screen | `ease-in-out` |
| Hover / color change | `ease` |
| Constant motion (marquee, progress) | `linear` |
| Default | `ease-out` |

**Never `ease-in` on UI.** It starts slow, delaying the exact moment the user is watching. `ease-out` at 200ms *feels* faster than `ease-in` at 200ms.

Built-in CSS easings are too weak for deliberate motion. Use these tokens (extend the codebase's tokens if it already has them; never add a parallel set):

```css
--ease-out: cubic-bezier(0.23, 1, 0.32, 1);        /* strong ease-out for UI */
--ease-in-out: cubic-bezier(0.77, 0, 0.175, 1);    /* strong ease-in-out for on-screen movement */
--ease-drawer: cubic-bezier(0.32, 0.72, 0, 1);     /* iOS-like drawer curve (Ionic) */
```

Need a curve that isn't here? Take it from [easing.dev](https://easing.dev/) or [easings.co](https://easings.co/). Don't hand-roll one.
<!-- /include: easing -->

<!-- include: duration -->
| Element | Duration |
| --- | --- |
| Button press feedback | 100–160ms |
| Tooltips, small popovers | 125–200ms |
| Dropdowns, selects | 150–250ms |
| Modals | 200–300ms |
| Drawers, sheets | 200–500ms with `--ease-drawer` (named exception) |
| Toasts | up to 400ms with `ease` (named exception) |
| Marketing / explanatory | Can be longer |

**UI animations stay under 300ms.** A 180ms dropdown feels more responsive than a 400ms one. The rule has exactly two named exceptions: drawers and sheets, whose travel distance earns the extra time, and toasts, which Sonner tunes slightly slower and with plain `ease` because that reads as elegant for an uninvited element. Anything else over 300ms on a UI element needs a stated reason.

Perceived speed compounds: a faster spinner makes the same load feel shorter; once one tooltip is open, its neighbours should open instantly (skip the delay *and* the animation); when list items enter and exit, the exit may run about 20% faster than the entry because the user has finished reading.
<!-- /include: duration -->

**Reach for a spring instead** when the motion is drag with momentum, an element that should feel alive, a gesture the user can interrupt or reverse, or decorative mouse-tracking. The configs, the bounce rule, and the no-library `linear()` spring curves are in [STANDARDS.md](STANDARDS.md) under Springs.

### 6. Interruption and exit

- **Transitions, not keyframes, for anything triggered rapidly** — toasts, toggles, anything a user can fire twice in a second. Transitions retarget from the current value; keyframes restart from zero.
- **Springs for gestures**, because they carry velocity through an interruption.
- **Exit the way it entered.** A toast that slides in from the bottom leaves through the bottom. Symmetric paths are what make swipe-to-dismiss feel obvious.
- **Asymmetric timing where the user is deciding.** Slow on the deliberate phase (a hold-to-confirm press: 2s linear), snappy on the system response (release: 200ms ease-out). A plain enter/exit pair may keep the same duration both ways.

### 7. Reduced motion and pointer gating

Ships with the animation, every time. The snippets (reduced motion keeps the fade and drops the movement; hover motion gated behind `@media (hover: hover) and (pointer: fine)`) are in [STANDARDS.md](STANDARDS.md) under Reduced motion. Reduced motion means **fewer and gentler** animations, not zero.

## Recipes

For ready-to-build implementations of the common cases — button press, dropdown, tooltip, modal, drawer, toast, accordion, stagger, hold-to-confirm, tab indicator, scroll reveal, drag-to-dismiss, same-document view transition, spring feel without a library — see [RECIPES.md](RECIPES.md). Load it whenever the request matches one of those components; start from the recipe rather than from a blank file.

## Never Ship

Self-check before you finish.

<!-- include: never-ship -->
Each row is an automatic block in `review-animations` and a self-check before `animate` finishes.

| Never | Instead |
| --- | --- |
| `transition: all` | Name the exact properties |
| `transform: scale(0)` entrance | `scale(0.95)` + `opacity: 0` |
| A trigger-anchored element (popover, dropdown, menu, tooltip) that only fades in | Scale from `0.95–0.97` with `transform-origin` at the trigger; pure fades stay for backdrops, same-spot crossfades and reduced-motion variants |
| `ease-in` on a UI element | `ease-out` or a strong custom curve |
| Built-in `ease-out` on a deliberate animation | `cubic-bezier(0.23, 1, 0.32, 1)` |
| Animation on a keyboard shortcut or 100+/day action | No animation |
| UI duration over 300ms outside the two named exceptions (drawers/sheets, toasts) with no stated reason | 150–250ms |
| `transform-origin: center` on a trigger-anchored popover | `var(--transform-origin)` (modals exempt) |
| Keyframes on toasts, toggles, rapidly-triggered elements | CSS transitions |
| Animating `width` / `height` / `margin` / `padding` / `top` / `left` outside the sanctioned exceptions | `transform` / `opacity` |
| Motion `x` / `y` / `scale` props on motion that runs while the page is busy | Full `transform` string |
| Driving a child's transform through a CSS variable on the parent | `transform` on the element itself |
| Ungated `:hover` motion | `@media (hover: hover) and (pointer: fine)` |
| Missing `prefers-reduced-motion` handling on movement | Gentler variant, not zero |
| Symmetric timing on a hold or press-and-release interaction | Slow the deliberate phase, snap the release |
| Everything entering at once where a group entrance belongs | 30–80ms stagger |
| Bounce on an element that arrived without momentum (a menu, a tooltip) | No bounce; reserve it for drag-to-dismiss and playful moments |
<!-- /include: never-ship -->

## Output

Write the code. Then, in at most a few lines:

- **The gate result** — frequency tier and the named purpose. If something in the request was rejected, say which and why.
- **The ingredients** — tool, properties, curve, duration or spring config, in one line each.
- **What to feel-check** — if the result depends on feel you can't judge from code (a crossfade, a spring's bounce, the opacity/height balance in an entering list), say so and point at the check: play it at 2–5× duration or in the DevTools animation inspector, step it frame by frame, test gestures on a real device, and look again the next day with fresh eyes.

Don't pad this into a report. The code is the deliverable.

## Tone

Opinionated and brief. When the honest answer is "this shouldn't animate," give it — that answer is the reason this skill exists. When feel genuinely can't be settled from code, say so instead of guessing at a value.
