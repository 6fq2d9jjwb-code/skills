# Expo Animation Recipes

Ready-to-build implementations for the cases that come up most in a React Native app. Start from the recipe, then adapt.

Curves are the `EASE_OUT` / `EASE_IN_OUT` / `EASE_SHEET` constants defined in SKILL.md.

---

## Two worklets you'll need everywhere

Momentum projection decides *where a flick was going*, so a fast short swipe commits and a slow long one doesn't. Rubber-banding makes a boundary resist instead of stopping dead.

```js
// Where the finger would come to rest if it kept decelerating.
// Apple's exponential-decay form — not the v²/2a from physics class.
function project(velocity, decelerationRate = 0.998) {
  'worklet';
  return ((velocity / 1000) * decelerationRate) / (1 - decelerationRate);
}

// The further past the edge, the less the element follows.
function rubberband(overshoot, dimension, constant = 0.55) {
  'worklet';
  return (overshoot * dimension * constant) / (dimension + constant * Math.abs(overshoot));
}
```

---

## Press feedback

Every pressable in the app. No gesture, no shared value — a CSS transition is the whole implementation.

```jsx
import Animated from 'react-native-reanimated';
import { Pressable, StyleSheet } from 'react-native';

function PressableScale({ onPress, children }) {
  const [pressed, setPressed] = useState(false);
  return (
    <Pressable
      onPress={onPress}
      onPressIn={() => setPressed(true)}
      onPressOut={() => setPressed(false)}
      hitSlop={12}
      pressRetentionOffset={16}
    >
      <Animated.View style={[styles.box, pressed && styles.pressed]}>{children}</Animated.View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  box: {
    transform: [{ scale: 1 }],
    transitionProperty: 'transform',
    transitionDuration: '120ms',
    transitionTimingFunction: 'cubic-bezier(0.23, 1, 0.32, 1)',
  },
  pressed: { transform: [{ scale: 0.97 }] },
});
```

`setState` is fine here — it fires twice per press, not per frame. `hitSlop` brings a small icon up to the 44pt target without growing it; `pressRetentionOffset` stops a slight finger drift from cancelling.

---

## Bottom sheet you can drag to dismiss

Before writing this: if the sheet is its own destination, use `presentation: 'formSheet'` (see **Screen transitions**) and get the platform's real sheet for free. Build this only when the sheet has to live inside an existing screen.

```jsx
const translateY = useSharedValue(0);
const context = useSharedValue(0);

const pan = Gesture.Pan()
  .activeOffsetY([-10, 10])   // let a horizontal swipe win; require intent before committing
  .onStart(() => {
    context.value = translateY.value;   // start from the current on-screen value, not from 0
  })
  .onUpdate((e) => {
    const next = context.value + e.translationY;
    // downward is free; upward past the top resists
    translateY.value = next >= 0 ? next : rubberband(next, HEIGHT);
  })
  .onEnd((e) => {
    const projected = translateY.value + project(e.velocityY);
    if (projected > HEIGHT * 0.4) {
      translateY.value = withSpring(HEIGHT, {
        duration: 300, dampingRatio: 1, velocity: e.velocityY, overshootClamping: true,
      }, (finished) => { if (finished) runOnJS(onClose)(); });
    } else {
      translateY.value = withSpring(0, { duration: 300, dampingRatio: 0.8, velocity: e.velocityY });
      runOnJS(Haptics.impactAsync)(Haptics.ImpactFeedbackStyle.Light);   // it snapped home
    }
  });

const sheetStyle = useAnimatedStyle(() => ({ transform: [{ translateY: translateY.value }] }));
```

The four details that separate this from a bad drag:

- **`onStart` captures the current value.** Without it, grabbing a sheet mid-animation teleports it — the animation must continue from where the eye last saw it.
- **Velocity decides, not distance.** `project()` means a quick flick dismisses even a few pixels down. Requiring 40% travel makes the sheet feel heavy.
- **Velocity is handed to the spring**, so there's no seam between the finger releasing and the animation continuing. This is the single detail that most separates "fluid" from "fine".
- **`overshootClamping` on dismissal** — otherwise the sheet springs past the bottom of the screen and flashes a gap.

The backdrop derives from the same value, so it's always in sync and costs nothing:

```jsx
const backdropStyle = useAnimatedStyle(() => ({
  opacity: interpolate(translateY.value, [0, HEIGHT], [1, 0], Extrapolation.CLAMP),
}));
```

---

## Swipe to delete a row

```jsx
const x = useSharedValue(0);

const pan = Gesture.Pan()
  .activeOffsetX([-10, 10])   // must declare the axis, or it fights the vertical scroll
  .onUpdate((e) => { x.value = Math.min(0, e.translationX); })
  .onEnd((e) => {
    const projected = x.value + project(e.velocityX);
    if (projected < -SWIPE_THRESHOLD) {
      x.value = withTiming(-WIDTH, { duration: 200, easing: EASE_OUT }, (f) => {
        if (f) runOnJS(onDelete)(id);
      });
    } else {
      x.value = withSpring(0, { duration: 300, dampingRatio: 1, velocity: e.velocityX });
    }
  });
```

Closing the gap the deleted row left is the list's job, not the row's:

```jsx
<Animated.FlatList data={items} itemLayoutAnimation={LinearTransition.duration(200)} ... />
```

`activeOffsetX` is the mobile-specific part. A pan handler inside a scroll view with no axis declared will steal vertical scrolls, and the list will feel broken in a way that looks like a scrolling bug rather than a gesture bug.

---

## Collapsing header on scroll

```jsx
const scrollY = useSharedValue(0);
const onScroll = useAnimatedScrollHandler((e) => { scrollY.value = e.contentOffset.y; });

const titleStyle = useAnimatedStyle(() => ({
  opacity: interpolate(scrollY.value, [0, 60], [1, 0], Extrapolation.CLAMP),
  transform: [{ translateY: interpolate(scrollY.value, [0, 60], [0, -12], Extrapolation.CLAMP) }],
}));

<Animated.ScrollView onScroll={onScroll} scrollEventThrottle={16}>
```

**Never animate the header's `height` to collapse it.** That runs a layout pass on the header and everything below it on every scroll frame — the one animation guaranteed to stutter, because it's competing with the scroll itself. Give the container a fixed height and translate the content inside it, clipping with `overflow: 'hidden'`.

`Extrapolation.CLAMP` is not optional: without it, scrolling past 60 keeps driving opacity negative and the header reappears inverted at the bottom of a long list.

---

## List entrances

```jsx
{items.map((item, i) => (
  <Animated.View key={item.id} entering={FadeInDown.duration(250).delay(i * 40)}>
```

Stagger 30–80ms. Longer feels slow, shorter reads as simultaneous.

**Never put `entering` on a row inside `FlatList`, `FlashList`, or any virtualized list.** Rows are recycled, so the animation re-fires every time one scrolls back into view — the list appears to flicker while the user scrolls. Animate the list container once on mount, or use `itemLayoutAnimation` for reflow only.

Entrance animations are for content the user asked for and is waiting on. A list they scroll past all day should already be there.

---

## Keyboard-synced UI

```jsx
import { useReanimatedKeyboardAnimation } from 'react-native-keyboard-controller';

const { height } = useReanimatedKeyboardAnimation();   // 0 → -keyboardHeight, on the UI thread
const footerStyle = useAnimatedStyle(() => ({ transform: [{ translateY: height.value }] }));
```

Never build this from `Keyboard.addListener` plus a timing animation. The keyboard rides a private system curve, the event arrives on the JS thread after the keyboard has already started moving, and any duration you pick will visibly lag or lead it. The UI must be driven by the keyboard's actual position, frame by frame.

---

## Tab / segmented indicator

Measure once, then animate transforms.

```jsx
const [layouts, setLayouts] = useState({});   // measured with onLayout, not per frame
const x = useSharedValue(0);
const w = useSharedValue(0);

useEffect(() => {
  const l = layouts[active];
  if (!l) return;
  x.value = withTiming(l.x, { duration: 250, easing: EASE_IN_OUT });
  w.value = withTiming(l.width, { duration: 250, easing: EASE_IN_OUT });
}, [active, layouts]);

const pillStyle = useAnimatedStyle(() => ({
  transform: [{ translateX: x.value }],
  width: w.value,
}));
```

This is the sanctioned `width` animation: the pill is absolutely positioned with no children, so nothing else re-lays-out, and its corner radius survives — `scaleX` would smear the corners into ovals.

`ease-in-out`, because the pill is moving across the screen rather than entering or leaving it. Fire `Haptics.selectionAsync()` on the press, not when the pill lands.

---

## Screen transitions (Expo Router)

Configure the native stack. Never rebuild a screen transition in JS: the native one runs on the platform side, keeps the interactive back gesture, and matches every other app on the device.

```jsx
<Stack screenOptions={{ animation: reduced ? 'fade' : 'default' }}>
  <Stack.Screen name="settings" options={{ animation: 'slide_from_right', animationMatchesGesture: true }} />
  <Stack.Screen name="compose" options={{ presentation: 'modal' }} />
  <Stack.Screen name="filter" options={{
    presentation: 'formSheet',
    sheetAllowedDetents: 'fitToContents',
    sheetGrabberVisible: true,
  }} />
</Stack>
```

| Navigation | Option |
| --- | --- |
| Deeper into a hierarchy | `animation: 'default'` — the platform push, unmodified |
| A self-contained task the user can abandon | `presentation: 'modal'` |
| A short interruption: picker, filter, share | `presentation: 'formSheet'` with detents |
| Between tabs | `animation: 'none'` |
| Reduced motion | `animation: 'fade'` |

`animationMatchesGesture: true` makes the iOS back swipe run your transition in reverse under the finger, instead of the default push. Set it whenever you set a custom `animation`, or dragging back looks like a different app than pushing forward.

---

## Toast

```jsx
<Animated.View
  entering={FadeInDown.duration(400).easing(EASE_OUT)}
  exiting={FadeOutDown.duration(300).easing(EASE_OUT)}
  style={{ position: 'absolute', bottom: insets.bottom + 16, left: 16, right: 16 }}
/>
```

- **It exits the way it entered.** Entering from the bottom and leaving to the side reads as two unrelated elements.
- **Exit ~20% faster than entry.** The user has finished reading; the arrival deserves the time, the departure doesn't.
- **Safe area insets, always.** A toast at `bottom: 16` sits under the home indicator on every modern iPhone.

If toasts stack and the list reflows, add `itemLayoutAnimation` and expect to tune the opacity against the reflow by eye — there's no formula for that pair. Look at it again the next day.

---

## Firing something once at a threshold

When a crossing point matters — a detent, a snap, a pull-to-refresh arming — don't poll it from JS and don't `runOnJS` every frame.

```jsx
const armed = useSharedValue(false);

useAnimatedReaction(
  () => pullDistance.value > REFRESH_THRESHOLD,
  (isArmed, wasArmed) => {
    if (isArmed !== wasArmed) {
      armed.value = isArmed;
      runOnJS(Haptics.impactAsync)(Haptics.ImpactFeedbackStyle.Light);
    }
  }
);
```

The comparison runs on the UI thread every frame; the JS call happens twice per pull. That's the pattern for every "do something when the animation reaches X".
