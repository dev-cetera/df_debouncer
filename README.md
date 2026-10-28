[![pub](https://img.shields.io/pub/v/df_debouncer.svg)](https://pub.dev/packages/df_debouncer)
[![tag](https://img.shields.io/badge/Tag-v0.6.0-purple?logo=github)](https://github.com/dev-cetera/df_debouncer/tree/v0.6.0)
[![discord](https://img.shields.io/badge/Discord-5865F2?logo=discord&logoColor=white)](https://discord.gg/gEQ8y2nfyX)
[![instagram](https://img.shields.io/badge/Instagram-E4405F?logo=instagram&logoColor=white)](https://www.instagram.com/dev_cetera/)
[![license](https://img.shields.io/badge/License-MIT-blue.svg)](https://raw.githubusercontent.com/dev-cetera/df_debouncer/main/LICENSE)

---

<!-- BEGIN _README_CONTENT -->

## Summary

Lightweight building blocks for controlling the rate of function calls in
response to rapid events:

- **`Debouncer`** — delays running an action until things have been quiet
  for a chosen window. Supports leading-edge (`onStart`), per-call
  (`onCall`), and trailing-edge (`onWaited`) callbacks, plus `finalize()`
  to flush a pending wait and `dispose()` to abandon it.
- **`Throttle`** — runs an action at most once per cool-down window.
  Ships with presets for common refresh rates (`Throttle24Hz`,
  `Throttle30Hz`, `Throttle48Hz`, `Throttle60Hz`, `Throttle120Hz`) and
  `ThrottleImmediate` for no-op throttling.
- **`CacheManager<T>`** — a small in-memory cache with optional per-entry
  expiration. Re-caching a key cancels its previous expiration timer, so
  values are never silently evicted by a stale timer.

## Installation

```sh
dart pub add df_debouncer
# or, for a Flutter project:
flutter pub add df_debouncer
```

## Usage

### Debouncer

```dart
import 'package:df_debouncer/df_debouncer.dart';

final autosave = Debouncer(
  delay: const Duration(milliseconds: 500),
  onStart: () => print('Saving...'),       // first call in a burst
  onCall:  () => print('Form changed'),    // every call
  onWaited: () => print('Saved to db'),    // 500ms after the last call
);

// Trigger from rapid events:
autosave();
autosave();
autosave();

// Flush a pending wait right now (e.g. in dispose):
await autosave.finalize();

// Or drop the pending wait without running onWaited:
autosave.dispose();
```

### Throttle

```dart
final throttle = Throttle60Hz(); // at most ~60 calls per second
void onPointerMove(Offset p) {
  throttle.run(() => repaint(p));
}

// Clear the cool-down early:
throttle.cancel();
```

### CacheManager

```dart
final cache = CacheManager<String>();
cache.cache('greeting', 'hello', cacheDuration: const Duration(minutes: 5));

final greeting = cache['greeting']; // 'hello' (or null once expired)

cache.remove('greeting');
cache.clear();
```

<!-- END _README_CONTENT -->

---

🔍 For more information, refer to the [API reference](https://pub.dev/documentation/df_debouncer/).

---

## 💬 Contributing and Discussions

This is an open-source project, and we warmly welcome contributions from everyone, regardless of experience level. Whether you're a seasoned developer or just starting out, contributing to this project is a fantastic way to learn, share your knowledge, and make a meaningful impact on the community.

### ☝️ Ways you can contribute

- **Find us on Discord:** Feel free to ask questions and engage with the community here: https://discord.gg/gEQ8y2nfyX.
- **Share your ideas:** Every perspective matters, and your ideas can spark innovation.
- **Help others:** Engage with other users by offering advice, solutions, or troubleshooting assistance.
- **Report bugs:** Help us identify and fix issues to make the project more robust.
- **Suggest improvements or new features:** Your ideas can help shape the future of the project.
- **Help clarify documentation:** Good documentation is key to accessibility. You can make it easier for others to get started by improving or expanding our documentation.
- **Write articles:** Share your knowledge by writing tutorials, guides, or blog posts about your experiences with the project. It's a great way to contribute and help others learn.

No matter how you choose to contribute, your involvement is greatly appreciated and valued!

## 👤 Author & Contact

- Website: [robertsolves.com.au](https://robertsolves.com.au)
- Organization: [dev-cetera.com](https://dev-cetera.com)
- Email: [robert@dev-cetera.com](mailto:robert@dev-cetera.com) or [hello@robertsolves.com.au](mailto:hello@robertsolves.com.au)

## LICENSE

This project is released under the [MIT License](https://raw.githubusercontent.com/dev-cetera/df_debouncer/main/LICENSE). See [LICENSE](https://raw.githubusercontent.com/dev-cetera/df_debouncer/main/LICENSE) for more information.
