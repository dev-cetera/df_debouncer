# Changelog

## [0.5.2]

- feat: `CacheManager` expiration consults `package:clock`'s ambient clock
  instead of `DateTime.now()`, so tests can drive cache expiration
  deterministically via `withClock(...)` (and `FakeAsync.withClock`).
  Production behaviour is unchanged.
- Add `clock: ^1.1.0` dependency.

## [0.5.1]

No consumer-visible changes; release covers tooling and CI only.

## 0.5.0

- **breaking**: require `df_safer_dart: ^0.20.0` (was `^0.17.3`) and
  `df_type: ^0.15.0` (was `^0.14.2`).
- **breaking**: `Debouncer.finalize()` now resets the started state, so the
  next `call()` re-fires `onStart`. Previously `_hasStarted` persisted
  across `finalize()` and the next call would skip `onStart`.
- feat: add `Debouncer.isPending` getter and `Debouncer.dispose()`.
- feat: add `Throttle.cancel()` to clear the cool-down early.
- feat: add `CacheManager.containsKey`, `.remove`, `.clear`, `.length`, and
  `.dispose()`.
- fix: `CacheManager` now cancels the previous expiration timer when
  re-caching an existing key — a stale timer no longer evicts the fresh
  value.
- fix: `CacheManager.cache` with a non-positive `cacheDuration` now evicts
  immediately instead of scheduling a delayed eviction.
- fix: `Throttle.run` re-arms the cool-down even if the action throws.
- fix: `ThrottleImmediate` (and any `Throttle` constructed with a zero or
  negative duration) no longer spawns a `Timer` between calls.
