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

final class Throttle {
  final Duration duration;
  bool _isThrottled = false;

  Throttle(this.duration);

  Throttle.immediate() : duration = const Duration();
  Throttle.to24hz() : duration = const Duration(milliseconds: 1000 ~/ 24);
  Throttle.to30hz() : duration = const Duration(milliseconds: 1000 ~/ 30);
  Throttle.to48hz() : duration = const Duration(milliseconds: 1000 ~/ 48);
  Throttle.to60hz() : duration = const Duration(milliseconds: 1000 ~/ 60);
  Throttle.to120hz() : duration = const Duration(milliseconds: 1000 ~/ 120);

  bool get isThrottled => _isThrottled;

  void run(void Function() action) {
    if (_isThrottled) return;
    _isThrottled = true;
    action();
    Future.delayed(duration, () => _isThrottled = false);
  }
}
