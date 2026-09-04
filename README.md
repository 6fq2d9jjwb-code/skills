<a href="https://animations.dev/">
<img width="320" height="168" alt="opengraph-image-pwu6ef" src="https://github.com/user-attachments/assets/a405a37f-1a1a-4e8d-8fd6-269ee6d4fba6" />
</a>

# Skills For Designers and Engineers

[![skills.sh](https://skills.sh/b/emilkowalski/skills)](https://skills.sh/emilkowalski/skills)

For designers and engineers to help them build better user interfaces.

Knowing whether you made a right choice when it comes to animations, or design in general, is hard. These skills aim to help you get to those right decisions faster.

They are based on my years of experience working at companies like Vercel and Linear.

All the skills here are a side-effect of domain-expertise. AI doesn’t replace such expertise, it amplifies what you can get out of it and makes you way better relative to others.

So learn to code, design, or develop expertise in any other field. It’s extremely valuable.

You can stay up to date with my skills here:

[Sign Up To The Newsletter](https://animations.dev/skills)

## About this fork

Maintained fork of [emilkowalski/skills](https://github.com/emilkowalski/skills). Same twelve skills, same philosophy, with the rules kept in one place and a few things fixed. What changed, by tier, is in [CHANGELOG.md](CHANGELOG.md).

- `shared/STANDARDS.md` is the single source of truth for every value (frequency gate, easing tokens, duration table, springs, performance, accessibility, the Never Ship table). `scripts/sync-standards.sh` copies it into the skills that use it and refreshes the included blocks inside their SKILL.md files; `scripts/check.sh` fails CI when a copy drifts, a link breaks, or a SKILL.md outgrows 500 lines. Edit the shared file, run the script, commit both.
- Version-sensitive advice (Swift 6.4 features, Reanimated 4, Gesture Handler v3, Expo Router native tabs) tells the agent to detect the installed toolchain first instead of trusting a date.
- `animation-vocabulary` accepts Chinese descriptions as well as English.

Install this fork:

```bash
npx skills@latest add 6fq2d9jjwb-code/skills
```

To pull upstream changes: `git fetch upstream && git merge upstream/main`, then `bash scripts/sync-standards.sh && bash scripts/check.sh` before committing.

## Install (upstream)

```bash
npx skills@latest add emilkowalski/skills
```

## Why use it?

Agents don’t have great taste

I have seen plenty of times that agents don’t pick the right ingredients for an animation. An `ease-in` easing for an enter animation when it’s supposed to be `ease-out` ([here’s why](https://emilkowal.ski/ui/7-practical-animation-tips#4.-choose-the-right-easing)). Or they choose a solid border instead of a semi-transparent shadow for your UIs.

All these small things compound and make your interface either amazing, or just... not that great.

As explained in [Agents with Taste](https://emilkowal.ski/ui/agents-with-taste), these skills list all the little mistakes agents can potentially make and explain how to fix them.

This is your shortcut to great interfaces. A shortcut to stand out in a sea of slop.

## Reference

- **[emil-design-eng](./skills/emil-design-eng/SKILL.md)** — The main skill that consists of mostly animation, but also some design advice.
- **[animate](./skills/animate/SKILL.md)** — Builds an animation from scratch while choosing the correct curve, duration, properties, and so on.
- **[animate-expo](./skills/animate-expo/SKILL.md)** — The same bar, for React Native and Expo: gestures, sheets, haptics, screen transitions, and keeping motion off the JS thread.
- **[review-animations](./skills/review-animations/SKILL.md)** — Review your animations in a strict way, based on my rules.
- **[improve-animations](./skills/improve-animations/SKILL.md)** — Audit all the animations in your codebase and get prioritized, self-contained plans that any agent can execute.
- **[find-animation-opportunities](./skills/find-animation-opportunities/SKILL.md)** — Search your UI for places that would genuinely benefit from motion, while also telling you what not to animate.
- **[animation-vocabulary](./skills/animation-vocabulary/SKILL.md)** — Get better animations from an AI by telling it exactly what you want by using the right words.
- **[apple-design](./skills/apple-design/SKILL.md)** — Apple’s principles for interface design and fluid motion, distilled from their WWDC design talks and translated for the web.
- **[write-swift](./skills/write-swift/SKILL.md)** — Write modern Swift. Includes: value types, Swift 6 concurrency, generics, performance, and Swift Testing.
- **[pick-ui-library](./skills/pick-ui-library/SKILL.md)** — Have your agent pick the right library for the task based on libraries I use and trust, instead of letting AI hand-roll a toast component or install an abandoned package.
- **[prototype](./skills/prototype/SKILL.md)** — Build multiple different versions of a UI piece you describe and go through them using a switcher.
- **[ask-sonner](./skills/ask-sonner/SKILL.md)** — Your guide to working with [Sonner](https://sonner.emilkowal.ski), my toast library. Contains setup, styling, recipes, and fixes for the most common issues.
