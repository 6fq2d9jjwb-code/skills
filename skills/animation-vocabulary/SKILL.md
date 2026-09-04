---
name: animation-vocabulary
description: Reverse-lookup glossary that turns a vague description of a web animation or motion effect into its exact term ("the bouncy thing when a popover opens" → Pop in; "the iOS rubber-band scroll" → Rubber-banding; "橡皮筋回弹" → Rubber-banding). Accepts the description in English or Chinese. Use when the user asks "what's it called when…" or "这个效果叫什么", or describes a motion effect without knowing its name and wants the right word to prompt an AI or designer with. For naming an effect, not designing or building one.
---

# Animation Vocabulary

Turn a vague description of a motion or effect into the precise term, so the user knows what to ask for.

## Quick Start

The user describes an effect loosely, in English or Chinese. You return the matching term(s) in this format:

```
**Stagger** — Animate several items one after another with a small delay between each, creating a cascade.
```

If several terms could fit, list the best match first, then 1–2 alternates with a one-line note on how they differ.

## Instructions

1. **Read for intent, not keywords.** Users describe what they *see* or *feel* ("springy", "slides off", "draws itself in", "一格一格跳"), not the technical name. Map the sensation to the glossary below.
2. **Quote the glossary verbatim.** Its English descriptions are authoritative — use them as-is, don't paraphrase.
3. **The English term is the answer.** It is what libraries, docs and other designers use. The Chinese words in parentheses are lookup keys so a Chinese description lands on the right term; when the user wrote in Chinese, lead with the English term, repeat the Chinese key in parentheses, then give the description in the user's language.
4. **Disambiguate close terms.** When two compete (*Clip-path* vs *Mask*, *Pop in* vs *Bounce*, *Shared element transition* vs *Layout animation*), contrast them so the user can pick.
5. **When nothing matches exactly,** name the closest term and say plainly it's an approximation, or describe the effect in the glossary's vocabulary (e.g. "that's a *stagger* of *scale-in* entrances").
6. **Stay within this glossary.** If a term genuinely isn't here, say so rather than inventing one — though you may explain the concept using these words.
7. **Keep it tight.** A naming question wants a name, not an essay. Lead with the term; expand only if asked.

## Examples

**Example 1 — feel-based**
User: "What's it called when a popover seems to grow out of the button you clicked instead of from its middle?"
Output:
```
**Origin-aware animation** — An element animates out of its trigger, like a popover growing from the button that opened it instead of from its own center which is the default in CSS.
```

**Example 2 — disambiguation**
User: "The thing where one image turns into another image."
Output:
```
**Morph** — One shape smoothly turns into another shape, e.g. Dynamic Island.

Close alternates:
- **Crossfade** — if they simply fade over each other in the same spot.
- **Shared element transition** — if an element travels and transforms from one position into another.
```

**Example 3 — physics feel**
User: "That iOS scroll where it resists and snaps back when you pull too far."
Output:
```
**Rubber-banding** — Resistance and snap-back when you drag past a boundary (the iOS overscroll feel).
```

**Example 4 — Chinese description**
User: "抽屉往下拉过头会有个被拉回来的手感，那个叫什么？"
Output:
```
**Rubber-banding**（橡皮筋回弹）— 拖过边界时有阻力、松手弹回，就是 iOS 滚动到头的那种手感。
```

## Glossary

Format: **English term**（中文查找词）— description. The Chinese is a lookup key, not a translation to output on its own.

### Entrances & Exits — how elements appear and disappear
- **Fade in / Fade out**（淡入、淡出）— Element appears or disappears by changing opacity.
- **Slide in**（滑入、从屏幕外滑进来）— Element enters by sliding in from off-screen (left, right, top, or bottom).
- **Scale in**（缩放入场、从小变大出现）— Element grows from smaller to full size as it appears, often paired with a fade.
- **Pop in**（弹入、带一点回弹地冒出来）— Element appears with a slight overshoot, like it bounces into place.
- **Reveal**（揭开显现、擦除出现）— Content is uncovered gradually, often by animating a clip-path or mask.
- **Enter / Exit**（入场、退场）— The animation an element plays when it's added to or removed from the screen.

### Sequencing & Timing — coordinating multiple elements or moments
- **Keyframes**（关键帧）— Defined points in an animation (0%, 50%, 100%) that the browser fills the gaps between.
- **Interpolation / Tween**（插值、补间）— Generating all the in-between frames between a start and end value, so motion is continuous.
- **Stagger**（错落入场、一个接一个出现）— Animate several items one after another with a small delay between each, creating a cascade.
- **Orchestration**（编排、多个动画统一节奏）— Deliberately timing multiple animations so they feel like one coordinated motion.
- **Delay**（延迟）— Time before an animation starts.
- **Duration**（时长）— How long an animation takes.
- **Fill mode**（填充模式、动画前后停在首帧或末帧）— Whether an element keeps its first or last frame's styles before the animation starts or after it ends (e.g. forwards).
- **Stepped animation**（步进动画、一格一格跳）— An animation that is divided into discrete steps, like a countdown timer.

### Movement & Transforms — changing an element's position, size, or angle
- **Translate**（位移、平移）— Move an element along the X or Y axis.
- **Scale**（缩放）— Make an element bigger or smaller.
- **Rotate**（旋转）— Spin an element around a point.
- **Skew**（倾斜、错切）— Slant an element along the X or Y axis, shearing it out of its rectangular shape.
- **3D tilt / Flip**（3D 倾斜、翻转）— Rotate in 3D space (rotateX / rotateY) to add depth.
- **Perspective**（透视、景深强弱）— How strong the 3D effect looks — a lower value exaggerates depth, like the viewer is closer.
- **Transform origin**（变换原点）— The anchor point a scale or rotation grows or spins from.
- **Origin-aware animation**（从触发点长出来、锚定来源）— An element animates out of its trigger, like a popover growing from the button that opened it instead of from its own center which is the default in CSS.

### Transitions Between States — connecting one state, view, or element to another
- **Crossfade**（交叉淡化、一个淡出一个淡入）— One element fades out as another fades in, in the same spot.
- **Continuity transition**（连续性过渡、前后状态连得上）— A change that keeps the user oriented by visually connecting before and after. For example, making the same rectangle bigger and smaller.
- **Morph**（形变、变形）— One shape smoothly turns into another shape, e.g. Dynamic Island.
- **Shared element transition**（共享元素过渡、缩略图飞成大图）— An element travels and transforms from one position into another, like a thumbnail expanding into a card.
- **Layout animation**（布局动画、位置尺寸变了平滑过去）— When an element's size or position changes, it animates to the new spot instead of snapping.
- **Accordion / Collapse**（手风琴、折叠展开）— A section smoothly expands and collapses its height to show or hide content.
- **Direction-aware transition**（方向感过渡、前进往一边后退往另一边）— Content slides one way going forward and the opposite way going back, so navigation has a sense of direction.

### Scroll — motion tied to scrolling or navigating between views
- **Scroll reveal**（滚动显现、滚到才出现）— Elements fade or slide into place as they enter the viewport.
- **Scroll-driven animation**（滚动驱动动画、进度跟着滚动走）— An animation whose progress is tied directly to scroll position.
- **Parallax**（视差）— Background and foreground move at different speeds while scrolling, creating depth.
- **Page transition**（页面转场）— An animation that plays when navigating from one page or route to another.
- **View transition**（视图过渡、浏览器自动在两个状态间变形）— The browser morphs between two states or pages, connecting shared elements.

### Feedback & Interaction — responding to the user's actions
- **Hover effect**（悬停效果、鼠标放上去的变化）— Visual change when the cursor moves over an element.
- **Press / Tap feedback**（按压反馈、按下去微微缩小）— A subtle scale-down when an element is clicked, so it feels physical.
- **Hold to confirm**（长按确认、按住进度填满）— A progress effect that fills up while the user holds a button.
- **Drag**（拖拽）— Moving an element by grabbing it, often with momentum when released.
- **Drag to reorder**（拖拽排序）— Dragging items in a list to rearrange them, while the others shift to make room.
- **Swipe to dismiss**（滑动关闭、划走）— Dragging an element off-screen to close it, like a drawer or toast.
- **Rubber-banding**（橡皮筋回弹、拉过头弹回来）— Resistance and snap-back when you drag past a boundary (the iOS overscroll feel).
- **Shake / Wiggle**（抖动、摇头、输错时左右晃）— A quick side-to-side jitter signaling an error or rejected input.
- **Ripple**（涟漪、水波纹）— A circle expanding from the point of a tap, confirming the press.

### Easing — how speed changes over an animation
- **Easing**（缓动）— The rate at which an animation speeds up or slows down.
- **Ease-out**（先快后慢）— Starts fast, ends slow. The default for most UI and anything responding to the user.
- **Ease-in**（先慢后快）— Starts slow, ends fast. Usually avoided; can feel sluggish.
- **Ease-in-out**（慢快慢）— Slow, fast, slow. Good for elements already on screen moving from A to B.
- **Linear**（匀速）— Constant speed. Avoid for UI; reserve for spinners or marquees.
- **Cubic-bezier**（贝塞尔曲线、自定义缓动）— A custom easing curve you define for precise control.
- **Asymmetric easing**（非对称缓动、加速和减速不一样快）— A curve that accelerates and decelerates at different rates. Feels more alive than a symmetric one.

### Spring Animations — physics-based motion as an alternative to fixed-duration easing
- **Spring**（弹簧动画、物理驱动）— Motion driven by physics (tension, mass, damping) rather than a set duration.
- **Stiffness / Tension**（刚度、张力、拉得多紧）— How strongly the spring pulls toward its target. Higher feels snappier.
- **Damping**（阻尼、多快停下来）— How quickly a spring settles. Lower damping means more bounce and oscillation.
- **Mass**（质量、有多重）— How heavy the animated element feels. More mass makes it slower and more sluggish.
- **Bounce**（回弹、过冲）— A spring that overshoots and settles, adding playfulness.
- **Perceptual duration**（感知时长）— How long a spring feels finished, even though it keeps micro-settling underneath.
- **Momentum**（动量、惯性）— Motion that carries velocity, especially after a drag or interruption.
- **Velocity**（速度、带方向的快慢）— How fast and in which direction an element is moving. A spring carries it into the next animation when interrupted, so a flicked element keeps its speed.
- **Interruptible animation**（可打断动画、半路可改道）— An animation that can be smoothly redirected mid-flight instead of finishing first.

### Looping & Ambient Motion — animations that run on their own
- **Marquee**（跑马灯）— Text or content that scrolls continuously in a loop.
- **Loop**（循环）— An animation that repeats, a set number of times or infinitely.
- **Alternate (yoyo)**（往返循环、正放再倒放）— A loop that plays forward then reverses each iteration, instead of jumping back to the start.
- **Orbit**（环绕、绕圈）— An element circling around another in a continuous path.
- **Pulse**（脉冲、呼吸、一缩一放）— A gentle repeating scale or opacity change to draw attention.
- **Float**（漂浮、轻轻上下浮动）— A gentle, continuous up-and-down drift that makes a static element feel alive and weightless.
- **Idle animation**（待机动画）— Subtle motion that plays while an element is just sitting there, waiting to be interacted with.

### Polish & Effects — the small touches that separate good from great
- **Blur**（模糊）— A blur filter used to soften an element or mask tiny imperfections.
- **Clip-path**（裁剪路径、硬边裁切）— Clipping an element to a shape, used for reveals, masks, and before/after sliders.
- **Mask**（遮罩、边缘可柔和）— Hiding or revealing parts of an element using a shape or gradient — like clip-path, but with soft, fadeable edges.
- **Before / after slider**（前后对比滑块）— A draggable divider that wipes between two overlaid images to compare them.
- **Line drawing**（线条描绘、路径自己画出来）— An SVG path that draws itself in, like an invisible pen tracing it.
- **Text morph**（文字形变、逐字变化）— Text that animates character by character when it changes, drawing attention to the new value.
- **Skeleton / Shimmer**（骨架屏、闪光扫过）— A placeholder with a moving sheen shown while content loads.
- **Number ticker**（数字滚动、数字翻牌）— Digits rolling or counting up to a value.
- **Tabular numbers**（等宽数字）— Fixed-width digits so numbers don't shift around as they change. Essential for tickers, timers, and counters.
- **Typewriter**（打字机效果、逐字打出来）— Text appearing one character at a time, as if being typed.

### Performance — what keeps motion smooth instead of stuttering
- **Frame rate (FPS)**（帧率）— Frames drawn per second. 60fps is the baseline for smooth motion; 120fps on newer displays.
- **Jank**（卡顿）— Visible stutter when the browser drops frames because it can't keep up with the animation.
- **Dropped frame**（掉帧）— A frame the browser missed its deadline to draw, causing a tiny hitch in motion.
- **Compositing**（合成、GPU 单独图层）— Letting the GPU move or fade an element on its own layer without redoing layout or paint.
- **will-change**（提前告诉浏览器要动）— A CSS hint that an element is about to animate, so the browser can promote it to its own layer ahead of time.
- **Layout thrashing**（布局抖动、每帧重排）— Animating properties like width, height, top, or left that force the browser to recalculate layout every frame, causing jank.

### Principles to Know — concepts that guide when and how to animate
- **Purposeful animation**（有目的的动画）— Motion should serve a function — orient, give feedback, show relationships — not just decorate.
- **Anticipation**（预备动作、先反向蓄力）— A small wind-up in the opposite direction before a move, hinting at what's about to happen.
- **Follow-through**（跟随、余势）— Parts of an element keep moving and settle slightly after the main motion stops, adding weight.
- **Squash & stretch**（挤压与拉伸）— Deforming an element as it moves to convey weight, speed, and flexibility.
- **Perceived performance**（感知性能、感觉更快）— The right animation makes an interface feel faster, even when it isn't.
- **Frequency of use**（使用频率）— The more often a user sees an animation, the shorter and subtler it should be.
- **Spatial consistency**（空间一致性、来处去处一致）— Animating so an element keeps its identity and position across states, so users never lose track of where things went.
- **Hardware acceleration**（硬件加速）— Animating transform and opacity lets the GPU keep motion smooth.
- **Reduced motion**（减弱动态效果、系统减少动画设置）— Respecting the user's prefers-reduced-motion setting by toning down or removing motion.
