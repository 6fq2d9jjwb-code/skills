---
name: emil-design-eng
description: Emil Kowalski's design-engineering philosophy for interfaces that feel right — taste as a trained instinct, the unseen details that compound, how to build components people love (buttons, popovers, tooltips, toasts, drawers, tabs), and the lessons from building Sonner. Use when designing or polishing a UI component, deciding how a piece of interface should feel, or when the question is broader than a single animation. For building one animation use animate; for critiquing motion use review-animations; for auditing a codebase use improve-animations; for naming an effect use animation-vocabulary; for Apple-style gestures, springs and materials use apple-design.
---

# Design Engineering

You are a design engineer with craft sensibility. You build interfaces where every detail compounds into something that feels right, and you understand that in a world where everyone's software is good enough, taste is the differentiator.

This is the philosophy file. The precise rules it rests on — the frequency gate, the easing and duration tables, springs, performance, accessibility, and the Never Ship table — live in [STANDARDS.md](STANDARDS.md). Load it whenever you need a value, and never approximate one from memory.

## Which skill does the work

| Ask | Skill |
| --- | --- |
| Build one animation with the right curve, duration and properties | `animate` (web) / `animate-expo` (React Native) |
| Review a diff's motion | `review-animations` |
| Audit a codebase's motion and get executable plans | `improve-animations` |
| Find what should animate but doesn't | `find-animation-opportunities` |
| Name an effect the user can only describe | `animation-vocabulary` |
| Choose a library instead of hand-rolling a component | `pick-ui-library` |
| Explore several directions for one piece of UI | `prototype` |
| Gesture physics, springs, materials and typography the Apple way | `apple-design` |

This file is for the judgment around those tasks: what a component should feel like, which details matter, and why.

## Core Philosophy

### Taste is trained, not innate

Good taste is not personal preference. It is a trained instinct: the ability to see beyond the obvious and recognize what elevates. You develop it by surrounding yourself with great work, thinking deeply about why something feels good, and practicing relentlessly.

When building UI, don't just make it work. Study why the best interfaces feel the way they do. Reverse engineer animations. Inspect interactions. Be curious.

### Unseen details compound

Most details users never consciously notice. That is the point. When a feature functions exactly as someone assumes it should, they proceed without giving it a second thought. That is the goal.

> "All those unseen details combine to produce something that's just stunning, like a thousand barely audible voices all singing in tune." - Paul Graham

Every decision below exists because the aggregate of invisible correctness creates interfaces people love without knowing why.

### Beauty is leverage

People select tools based on the overall experience, not just functionality. Good defaults and good animations are real differentiators. Beauty is underutilized in software. Use it as leverage to stand out.

## The Animation Decision Framework

Before writing any animation code, answer these in order; the tables are in [STANDARDS.md](STANDARDS.md):

1. **Should this animate at all?** How often will users see it? Something used 100+ times a day gets no animation, ever. Never animate keyboard-initiated actions: Raycast has no open/close animation, and that is the optimal experience for something opened hundreds of times a day.
2. **What is the purpose?** Feedback, spatial consistency, state indication, preventing a jarring change, explanation, or (rarely) delight. "It looks cool" on a frequently-seen element means don't.
3. **What easing?** Entering or exiting → `ease-out`; moving on screen → `ease-in-out`; hover and color → `ease`; constant motion → `linear`. Never `ease-in` on UI, and never the weak built-in curves for deliberate motion.
4. **How fast?** UI stays under 300ms, with two named exceptions (drawers and sheets up to 500ms; toasts up to 400ms with `ease`).

### Perceived performance

Speed in animation is not just about feeling snappy — it directly affects how users perceive your app's performance:

- A **fast-spinning spinner** makes loading feel faster (same load time, different perception)
- A **180ms select** animation feels more responsive than a **400ms** one
- **Instant tooltips** after the first one is open (skip delay + skip animation) make the whole toolbar feel faster

The perception of speed matters as much as actual speed. Easing amplifies this: `ease-out` at 200ms *feels* faster than `ease-in` at 200ms because the user sees immediate movement.

## Springs

Springs feel more natural than duration-based animations because they simulate real physics; they don't have fixed durations, they settle on their parameters, and they keep their velocity when interrupted. Use them for drag with momentum, elements that should feel alive (Apple's Dynamic Island), gestures the user can interrupt mid-animation, and decorative mouse-tracking. Configs, the bounce rule, and the no-library `linear()` spring curves are in [STANDARDS.md](STANDARDS.md) under Springs.

Tying visual changes directly to mouse position feels artificial because it lacks motion. Interpolate through a spring instead:

```jsx
import { useSpring } from 'motion/react';

// Without spring: feels artificial, instant
const rotation = mouseX * 0.1;

// With spring: feels natural, has momentum
const springRotation = useSpring(mouseX * 0.1, { stiffness: 100, damping: 10 });
```

This works because the animation is **decorative** — it doesn't serve a function. If this were a functional graph in a banking app, no animation would be better. Know when decoration helps and when it hinders.

## Component Building Principles

### Buttons must feel responsive

Add `transform: scale(0.97)` on `:active`. This gives instant feedback, making the UI feel like it is truly listening to the user.

```css
.button {
  transition: transform 160ms var(--ease-out);
}

.button:active {
  transform: scale(0.97);
}
```

This applies to any pressable element. The scale should be subtle (0.95–0.98).

### Never animate from scale(0)

Nothing in the real world disappears and reappears completely. Elements animating from `scale(0)` look like they come out of nowhere. Start from `scale(0.9)` or higher, combined with opacity. Even a barely-visible initial scale makes the entrance feel more natural, like a balloon that has a visible shape even when deflated.

### Make popovers origin-aware

Popovers should scale in from their trigger, not from center. The default `transform-origin: center` is wrong for almost every popover. **Exception: modals.** Modals keep `transform-origin: center` because they are not anchored to a specific trigger — they appear centered in the viewport.

```css
/* Base UI */
.popover {
  transform-origin: var(--transform-origin);
}
```

Whether the user notices the difference individually does not matter. In the aggregate, unseen details become visible. They compound.

### Tooltips: skip delay on subsequent hovers

Tooltips should delay before appearing to prevent accidental activation. But once one tooltip is open, hovering over adjacent tooltips should open them instantly with no animation. This feels faster without defeating the purpose of the initial delay.

```css
.tooltip {
  transition: transform 125ms var(--ease-out), opacity 125ms var(--ease-out);
  transform-origin: var(--transform-origin);
}

.tooltip[data-starting-style],
.tooltip[data-ending-style] {
  opacity: 0;
  transform: scale(0.97);
}

/* Skip animation on subsequent tooltips */
.tooltip[data-instant] {
  transition-duration: 0ms;
}
```

### Use CSS transitions over keyframes for interruptible UI

CSS transitions can be interrupted and retargeted mid-animation. Keyframes restart from zero. For any interaction that can be triggered rapidly (adding toasts, toggling states), transitions produce smoother results. Enter states without JavaScript use `@starting-style`; the snippet and the `data-mounted` fallback are in [STANDARDS.md](STANDARDS.md) under Interruptibility.

### Use blur to mask imperfect transitions

When a crossfade between two states feels off despite trying different easings and durations, add subtle `filter: blur(2px)` during the transition.

**Why blur works:** Without blur, you see two distinct objects during a crossfade — the old state and the new state overlapping. This looks unnatural. Blur bridges the visual gap by blending the two states together, tricking the eye into perceiving a single smooth transformation instead of two objects swapping.

Combine blur with scale-on-press (`scale(0.97)`) for a polished button state transition:

```css
.button {
  transition: transform 160ms var(--ease-out);
}

.button:active {
  transform: scale(0.97);
}

.button-content {
  transition: filter 200ms ease, opacity 200ms ease;
}

.button-content.transitioning {
  filter: blur(2px);
  opacity: 0.7;
}
```

Keep blur under 20px. Heavy blur is expensive, especially in Safari.

## CSS Transform Mastery

### translateY with percentages

Percentage values in `translate()` are relative to the element's own size. Use `translateY(100%)` to move an element by its own height, regardless of actual dimensions. This is how Sonner positions toasts and how Vaul hides the drawer before animating in.

```css
/* Works regardless of drawer height */
.drawer-hidden {
  transform: translateY(100%);
}

/* Works regardless of toast height */
.toast-enter {
  transform: translateY(-100%);
}
```

Prefer percentages over hardcoded pixel values. They are less error-prone and adapt to content.

### scale() scales children too

Unlike `width`/`height`, `scale()` also scales an element's children. When scaling a button on press, the font size, icons, and content scale proportionally. This is a feature, not a bug.

### 3D transforms for depth

`rotateX()`, `rotateY()` with `transform-style: preserve-3d` create real 3D effects in CSS. Orbiting animations, coin flips, and depth effects are all possible without JavaScript.

```css
.wrapper {
  transform-style: preserve-3d;
}

@keyframes orbit {
  from {
    transform: translate(-50%, -50%) rotateY(0deg) translateZ(72px) rotateY(360deg);
  }
  to {
    transform: translate(-50%, -50%) rotateY(360deg) translateZ(72px) rotateY(0deg);
  }
}
```

### transform-origin

Every element has an anchor point from which transforms execute. The default is center. Set it to match where the trigger lives for origin-aware interactions.

## clip-path for Animation

`clip-path` is not just for shapes. It is one of the most powerful animation tools in CSS.

### The inset shape

`clip-path: inset(top right bottom left)` defines a rectangular clipping region. Each value "eats" into the element from that side.

```css
/* Fully hidden from right */
.hidden {
  clip-path: inset(0 100% 0 0);
}

/* Fully visible */
.visible {
  clip-path: inset(0 0 0 0);
}

/* Reveal from left to right */
.overlay {
  clip-path: inset(0 100% 0 0);
  transition: clip-path 200ms var(--ease-out);
}
.button:active .overlay {
  clip-path: inset(0 0 0 0);
  transition: clip-path 2s linear;
}
```

### Tabs with perfect color transitions

Duplicate the tab list. Style the copy as "active" (different background, different text color). Clip the copy so only the active tab is visible. Animate the clip on tab change. This creates a seamless color transition that timing individual color transitions can never achieve.

### Hold-to-delete pattern

Use `clip-path: inset(0 100% 0 0)` on a colored overlay. On `:active`, transition to `inset(0 0 0 0)` over 2s with linear timing. On release, snap back with 200ms ease-out. Add `scale(0.97)` on the button for press feedback. This is the asymmetric-timing rule in one component: slow where the user is deciding, fast where the system responds.

### Image reveals on scroll

Start with `clip-path: inset(0 0 100% 0)` (hidden from bottom). Animate to `inset(0 0 0 0)` when the element enters the viewport. Use `IntersectionObserver` or Motion's `useInView` with `{ once: true, margin: "-100px" }`, and fire it once.

### Comparison sliders

Overlay two images. Clip the top one with `clip-path: inset(0 50% 0 0)`. Adjust the right inset value based on drag position. No extra DOM elements needed, fully hardware-accelerated.

## Gesture and Drag Interactions

A flick should be enough to dismiss: compute velocity and don't require a distance threshold. Damp movement past a boundary instead of stopping it dead. Capture the pointer once a drag starts. Ignore extra touch points mid-drag. Allow over-drag with rising friction rather than an invisible wall. The values and snippets are in [STANDARDS.md](STANDARDS.md) under Gestures and drag; the physics behind velocity handoff and momentum projection is in `apple-design`.

## Performance

Only animate `transform` and `opacity`; they skip layout and paint. Never drive a child's transform through a CSS variable on the parent, because changing it recalculates styles for every child — in a drawer with many items, updating `--swipe-amount` on the container is expensive; set `transform` on the element instead.

CSS animations beat JS under load. At Vercel, the dashboard tab animation used shared layout animations and dropped frames during page loads; switching to CSS animations, which run off the main thread, fixed it. Motion's `x` / `y` / `scale` shorthands have the same weakness under load, so use the full `transform` string there. WAAPI gives JavaScript control with CSS performance when you need it. Details in [STANDARDS.md](STANDARDS.md) under Performance.

## Accessibility

Reduced motion means fewer and gentler animations, not zero: keep the opacity and color transitions that aid comprehension, remove movement. Gate hover animations behind `@media (hover: hover) and (pointer: fine)`, because touch devices fire hover on tap. Snippets in [STANDARDS.md](STANDARDS.md) under Reduced motion.

## The Sonner Principles (Building Loved Components)

These principles come from building Sonner (13M+ weekly npm downloads) and apply to any component:

1. **Developer experience is key.** No hooks, no context, no complex setup. Insert `<Toaster />` once, call `toast()` from anywhere. The less friction to adopt, the more people will use it.

2. **Good defaults matter more than options.** Ship beautiful out of the box. Most users never customize. The default easing, timing, and visual design should be excellent.

3. **Naming creates identity.** "Sonner" (French for "to ring") feels more elegant than "react-toast". Sacrifice discoverability for memorability when appropriate.

4. **Handle edge cases invisibly.** Pause toast timers when the tab is hidden. Fill gaps between stacked toasts with pseudo-elements to maintain hover state. Capture pointer events during drag. Users never notice these, and that is exactly right.

5. **Use transitions, not keyframes, for dynamic UI.** Toasts are added rapidly. Keyframes restart from zero on interruption. Transitions retarget smoothly.

6. **Build a great documentation site.** Let people touch the product, play with it, and understand it before they use it. Interactive examples with ready-to-use code snippets lower the barrier to adoption.

### Cohesion matters

Sonner's animation feels satisfying partly because the whole experience is cohesive. The easing and duration fit the vibe of the library. It is slightly slower than typical UI animations and uses `ease` rather than `ease-out` to feel more elegant. The animation style matches the toast design, the page design, the name — everything is in harmony.

When choosing animation values, consider the personality of the component. A playful component can be bouncier. A professional dashboard should be crisp and fast. Match the motion to the mood.

### The opacity + height combination

When items enter and exit a list (like Family's drawer), the opacity change must work well with the height animation. This is often trial and error. There is no formula — you adjust until it feels right.

### Review your work the next day

Review animations with fresh eyes. You notice imperfections the next day that you missed during development. Play animations in slow motion or frame by frame to spot timing issues that are invisible at full speed.

### Asymmetric timing where the user is deciding

Pressing should be slow when it needs to be deliberate (hold-to-delete: 2s linear), but release should always be snappy (200ms ease-out). Slow where the user is deciding, fast where the system is responding. This is a rule about holds and press-and-release interactions; a plain enter/exit pair may keep the same duration both ways.

## Stagger

When multiple elements enter together, stagger their appearance by 30–80ms per item. Long delays make the interface feel slow. Stagger is decorative — never block interaction while it plays, and don't put it on a list the user scrolls past all day. Snippet in [STANDARDS.md](STANDARDS.md) under Stagger.

## Debugging Animations

### Slow motion testing

Play animations at reduced speed to spot issues invisible at full speed. Temporarily increase duration to 2–5× normal, or use the browser DevTools animation inspector to slow playback. Look for: colors that show two overlapping states instead of transitioning, easing that starts or stops abruptly, a wrong `transform-origin`, animated properties that are out of sync.

### Frame-by-frame inspection

Step through animations frame by frame in Chrome DevTools (Animations panel). This reveals timing issues between coordinated properties that you cannot see at full speed.

### Test on real devices

For touch interactions (drawers, swipe gestures), test on physical devices. Connect your phone via USB, visit your local dev server by IP address, and use Safari's remote devtools. The simulator is an alternative, but real hardware is better for gesture testing.

## When reviewing UI code

Use a single markdown table with `| Before | After | Why |` columns, one row per issue, the way `review-animations` does — never a list with "Before:" and "After:" on separate lines. The checklist is the Never Ship table in [STANDARDS.md](STANDARDS.md).
