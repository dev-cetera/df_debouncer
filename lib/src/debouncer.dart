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

import 'package:df_safer_dart/df_safer_dart.dart';

typedef _VoidCallback = FutureOr<void> Function();

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A practical Debouncer for optimizing performance by controlling the
/// frequency of function calls in response to rapid events.
final class Debouncer {
  //
  //
  //

  Timer? _timer;
  bool _hasStarted = false;
  final _sequencer = SafeSequencer();

  /// The function to call once at the very beginning.
  final _VoidCallback? _onStart;
  _VoidCallback? get onStart => _onStart;

  /// The function to call after the [delay] has passed.
  final _VoidCallback? _onWaited;
  _VoidCallback? get onWaited => _onWaited;

  /// The function to call immediately.
  final _VoidCallback? _onCall;
  _VoidCallback? get onCall => _onCall;

  /// The delay before calling the [_onWaited] function.
  final Duration delay;

  //
  //
  //

  Debouncer({
    required this.delay,
    FutureOr<void> Function()? onStart,
    FutureOr<void> Function()? onWaited,
    FutureOr<void> Function()? onCall,
  })  : _onCall = onCall,
        _onWaited = onWaited,
        _onStart = onStart;

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
      if (_onStart != null) {
        _sequencer.add(_onStart);
      }
      if (onStart != null) {
        _sequencer.add(onStart);
      }
      _hasStarted = true;
    }
    if (_onCall != null) {
      _sequencer.add(_onCall);
    }
    if (onCall != null) {
      _sequencer.add(onCall);
    }
    _timer = Timer(delay, () {
      if (_onWaited != null) {
        _sequencer.add(_onWaited);
      }
      if (onWaited != null) {
        _sequencer.add(onWaited);
      }
      _hasStarted = false;
    });

    return _sequencer.last.value;
  }

  //
  //
  //

  /// Finalizes the debouncer and calls the [onWaited] function.
  FutureOr<void> finalize({FutureOr<void> Function()? onWaited}) {
    if (cancel()) {
      if (_onWaited != null) {
        _sequencer.add(_onWaited);
      }
      if (onWaited != null) {
        _sequencer.add(onWaited);
      }
      return _sequencer.last.value;
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
