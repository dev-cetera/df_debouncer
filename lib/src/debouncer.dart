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

import 'dart:async' show FutureOr, Timer;

import 'package:df_type/src/future_or/_sequential.dart' show Sequential;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A practical Debouncer for optimizing performance by controlling the
/// frequency of function calls in response to rapid events.
final class Debouncer {
  //
  //
  //

  Timer? _timer;
  bool _hasStarted = false;
  final _sequential = Sequential();

  /// The function to call once at the very beginning.
  final FutureOr<void> Function()? onStart;

  /// The function to call after the [delay] has passed.
  final FutureOr<void> Function()? onWaited;

  /// The function to call immediately.
  final FutureOr<void> Function()? onCall;

  /// The delay before calling the [onWaited] function.
  final Duration delay;

  //
  //
  //

  Debouncer({
    required this.delay,
    this.onStart,
    this.onWaited,
    this.onCall,
  });

  //
  //
  //

  /// Calls the [onCall] function and then waits for [delay] before calling the
  /// [onWaited] function.
  FutureOr<void> call({
    FutureOr<void> Function()? onStart,
    FutureOr<void> Function()? onWaited,
    FutureOr<void> Function()? onCall,
  }) {
    cancel();
    if (!_hasStarted) {
      if (this.onStart != null) {
        _sequential.add((_) => this.onStart!());
      }
      if (onStart != null) {
        _sequential.add((_) => onStart());
      }
      _hasStarted = true;
    }
    if (this.onCall != null) {
      _sequential.add((_) => this.onCall!());
    }
    if (onCall != null) {
      _sequential.add((_) => onCall());
    }
    _timer = Timer(
      delay,
      () {
        if (this.onWaited != null) {
          _sequential.add((_) => this.onWaited!());
        }
        if (onWaited != null) {
          _sequential.add((_) => onWaited());
        }
        _hasStarted = false;
      },
    );

    return _sequential.last;
  }

  //
  //
  //

  /// Finalizes the debouncer and calls the [onWaited] function.
  FutureOr<void> finalize({FutureOr<void> Function()? onWaited}) {
    if (cancel()) {
      if (this.onWaited != null) {
        _sequential.add((_) => this.onWaited!());
      }
      if (onWaited != null) {
        _sequential.add((_) => onWaited());
      }
      return _sequential.last;
    }
  }

  //
  //
  //

  /// Cancels the debouncer.
  bool cancel() {
    if (_timer != null) {
      if (_timer!.isActive) {
        _timer!.cancel();
        _timer = null;
        return true;
      }
    }
    return false;
  }
}
