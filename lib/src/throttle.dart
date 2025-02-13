//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Dart/Flutter (DF) Packages by dev-cetera.com & contributors. The use of this
// source code is governed by an MIT-style license described in the LICENSE
// file located in this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

/// Base class for throttle functionality.
final class Throttle {
  final Duration duration;
  bool _isThrottled = false;

  Throttle(this.duration);

  bool get isThrottled => _isThrottled;

  void run(void Function() action) {
    if (_isThrottled) return;
    _isThrottled = true;
    action();
    Future.delayed(duration, () => _isThrottled = false);
  }
}

/// Throttle with no delay.
final class ThrottleImmediate extends Throttle {
  ThrottleImmediate() : super(const Duration());
}

/// Throttle at 24 Hz.
final class Throttle24Hz extends Throttle {
  Throttle24Hz() : super(const Duration(milliseconds: 1000 ~/ 24));
}

/// Throttle at 30 Hz.
final class Throttle30Hz extends Throttle {
  Throttle30Hz() : super(const Duration(milliseconds: 1000 ~/ 30));
}

/// Throttle at 48 Hz.
final class Throttle48Hz extends Throttle {
  Throttle48Hz() : super(const Duration(milliseconds: 1000 ~/ 48));
}

/// Throttle at 60 Hz.
final class Throttle60Hz extends Throttle {
  Throttle60Hz() : super(const Duration(milliseconds: 1000 ~/ 60));
}

/// Throttle at 120 Hz.
final class Throttle120Hz extends Throttle {
  Throttle120Hz() : super(const Duration(milliseconds: 1000 ~/ 120));
}
