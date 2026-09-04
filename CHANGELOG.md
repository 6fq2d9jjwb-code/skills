# Changelog (fork)

All changes relative to upstream `emilkowalski/skills` at d23d7f8 (2026-08-21). Line references are to upstream files.

## Tier A — factual errors

- **ask-sonner** `SKILL.md` (Recipes) and `API.md` (Functions): `toast.getActiveToasts()` does not exist. Sonner 2.0.8 exports `toast.getToasts()` (active) and `toast.getHistory()` (all, dismissed included). Verified against the package's `dist/index.d.ts`.
- **write-swift** §3 "The rule that changed": "in Swift 6.2, marking a function `async` does not move it off the current actor" described a build setting as a compiler version. The behavior comes from the `NonisolatedNonsendingByDefault` upcoming feature (SE-0461), which Approachable Concurrency enables; without it a `nonisolated async` function still hops to the concurrent pool and `@concurrent` is unavailable. The section now says so, and the header tells the agent to detect the toolchain and the setting first.

## Tier B — internal contradictions

- **Enter/exit timing.** `emil-design-eng` line 673 flagged any symmetric enter/exit as a defect, while every `animate` recipe (popover, tooltip, modal) is symmetric and `review-animations` only flagged holds. The rule is now scoped, in one place (`STANDARDS.md` § Asymmetric timing): it applies to hold and press-and-release interactions; plain enter/exit pairs may be symmetric.
- **Pure fades.** `review-animations` line 48 blocked "pure-fade entrances with no initial transform", which would have flagged `animate`'s own modal backdrop, every crossfade, and every reduced-motion variant. The trigger is now "a trigger-anchored element that only fades in"; backdrops, same-spot crossfades and reduced-motion variants are named exceptions (§ Physicality, § Never ship).
- **Toast duration.** `animate/RECIPES.md` line 133 used 400ms `ease` (Sonner's personality) while `animate-expo/RECIPES.md` line 358 said the 300ms cap admits no toast exception. Toasts are now one of two named exceptions to the 300ms rule (up to 400ms, plain `ease`); the Expo recipe keeps 300/250 and says why.
- **Duration table vs. the 300ms rule.** "Modals, drawers 200–500ms" sat next to "UI stays under 300ms" with a 500ms drawer recipe and a Never Ship row for "over 300ms". The table now separates modals (200–300ms) from drawers/sheets (200–500ms, named exception), and the Never Ship row names the two exceptions.

## Tier C — structure and maintenance

- **Single source of truth.** The frequency gate, purpose list, tool table, property rules, easing tokens, duration table, physicality, springs, interruptibility, asymmetric timing, performance, transforms/clip-path, gestures, crossfade masking, stagger, accessibility, debugging, cohesion and the Never Ship table were copied by hand into six skills (`emil-design-eng`, `animate`, `review-animations/STANDARDS.md`, `improve-animations/AUDIT.md`, `find-animation-opportunities`, `prototype`) and had already drifted (Tier B). They now live in `shared/STANDARDS.md`; `scripts/sync-standards.sh` generates the per-skill `STANDARDS.md` copies and splices the marked blocks into `animate`, `review-animations` and `find-animation-opportunities`; `scripts/check.sh` and the GitHub Actions workflow fail on drift.
- **emil-design-eng** rewritten from 674 lines to a routing table plus the content no other skill carries (philosophy, component principles, transforms, clip-path techniques, the Sonner principles, debugging). Its description now says when to use it and which sibling skill to use instead; the "Initial Response" block (an advertisement returned instead of an answer when invoked without a question) is gone.
- **Detect, don't date.** `write-swift` no longer calls Swift 6.3 "the current release as of August 2026" or 6.4 "unreleased"; ⚠ rows are "needs Swift 6.4 or later" and the header says to run `swift --version`. `animate-expo` gained a "Detect the stack first" section (Expo SDK, Reanimated major, Gesture Handler major, New Architecture) and no longer states which Gesture Handler major Expo installs.
- **animation-vocabulary**: removed the maintainer note about syncing with a website.
- **Package names**: React examples import from `motion/react` (formerly `framer-motion`); vanilla examples from `motion`.
- **Reduced-motion snippet** referenced an undefined `@keyframes fade` in four files; it is now a self-contained transition that keeps the fade and neutralizes the transform.
- **improve-animations/AUDIT.md** is now hunt lists per category over the shared standards instead of a second copy of the values; `PLAN-TEMPLATE.md` and `SKILL.md` point executors at `STANDARDS.md` for values.

## Tier D — gaps

- **Tools table** (`STANDARDS.md` § Tools, included in `animate`): added CSS scroll-driven animations, the View Transitions API, and CSS `linear()` spring easing.
- **animate/RECIPES.md**: same-document view transition recipe (with feature detection and reduced-motion skip); "spring feel without a library" recipe; scroll-driven progress example with the note that scroll-driven animation is the wrong tool for a one-time reveal; `interpolate-size: allow-keywords` as progressive enhancement for accordions.
- **Springs** (`STANDARDS.md`): two sampled `linear()` spring curves (`--spring-settle`, critically damped; `--spring-bounce`, damping ratio 0.8) generated from the damped-oscillator equations over a 500ms window, with the caveat that a `linear()` transition cannot carry release velocity.

## Tier E — adaptation

- **animation-vocabulary**: every glossary term carries Chinese lookup keys; the description and instructions accept Chinese descriptions and answer with the English term first.
- **prototype**: before naming directions, ask the person for imagery, color, temperament and taboos (or state the assumptions if nobody is available); variants must respect the taboos.
- **pick-ui-library**: check that a package is still maintained before installing it; the list's curation date is stated.

## Notes

- Cross-references to `animate-expo` and `pick-ui-library` are phrased as "when it is installed", so any subset of the skills can be installed without a routing row pointing at a skill that isn't there.
