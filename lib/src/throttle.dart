//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Copyright © dev-cetera.com & contributors.
//
// The use of this source code is governed by an MIT-style license described in
// the LICENSE file located in this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import 'dart:async' show Timer;

/// Limits the execution rate of a function.
///
/// Once an action is run, subsequent calls are ignored for the specified
/// [duration] (the "cool-down" period).
final class Throttle {
  /// The cool-down period after an action is executed.
  final Duration duration;

  bool _isThrottled = false;
  Timer? _timer;

  /// Creates a throttle with a specific cool-down [duration].
  Throttle(this.duration);

  /// Returns `true` if the throttle is currently in its cool-down period.
  bool get isThrottled => _isThrottled;

  /// Executes the [action] if the throttle is not currently active.
  ///
  /// If run, the throttle becomes active immediately and will ignore subsequent
  /// calls until the [duration] has passed.
  void run(void Function() action) {
    if (_isThrottled) return;
    _isThrottled = true;
    try {
      action();
    } finally {
      // A zero/negative duration means "no cool-down" — keep the throttle
      // open for the next call instead of paying for a Timer hop.
      if (duration <= Duration.zero) {
        _isThrottled = false;
      } else {
        _timer?.cancel();
        _timer = Timer(duration, () {
          _isThrottled = false;
          _timer = null;
        });
      }
    }
  }

  /// Cancels any pending cool-down and resets the throttle so the next call
  /// to [run] will execute immediately.
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _isThrottled = false;
  }
}

/// A throttle that runs immediately and has no cool-down period.
///
/// This effectively disables throttling, allowing every call to `run` to
/// execute.
final class ThrottleImmediate extends Throttle {
  ThrottleImmediate() : super(Duration.zero);
}

/// A throttle that limits execution to approximately 24 times per second.
final class Throttle24Hz extends Throttle {
  Throttle24Hz() : super(const Duration(milliseconds: 1000 ~/ 24));
}

/// A throttle that limits execution to approximately 30 times per second.
final class Throttle30Hz extends Throttle {
  Throttle30Hz() : super(const Duration(milliseconds: 1000 ~/ 30));
}

/// A throttle that limits execution to approximately 48 times per second.
final class Throttle48Hz extends Throttle {
  Throttle48Hz() : super(const Duration(milliseconds: 1000 ~/ 48));
}

/// A throttle that limits execution to approximately 60 times per second.
final class Throttle60Hz extends Throttle {
  Throttle60Hz() : super(const Duration(milliseconds: 1000 ~/ 60));
}

/// A throttle that limits execution to approximately 120 times per second.
final class Throttle120Hz extends Throttle {
  Throttle120Hz() : super(const Duration(milliseconds: 1000 ~/ 120));
}
