import 'dart:async';

import 'package:flutter/widgets.dart';

/// UI-only countdown for a PIN lockout reported by `PinService`.
///
/// `PinService` stays the authority; this only refreshes the remaining
/// seconds and re-enables the keypad when the period ends.
mixin PinLockoutCountdown<T extends StatefulWidget> on State<T> {
  Timer? _lockoutTimer;
  DateTime? _lockoutEnds;

  int get lockoutSeconds {
    final ends = _lockoutEnds;
    if (ends == null) return 0;
    final ms = ends.difference(DateTime.now()).inMilliseconds;
    return ms <= 0 ? 0 : (ms / 1000).ceil();
  }

  bool get lockedOut => lockoutSeconds > 0;

  void startLockout(Duration remaining) {
    _lockoutTimer?.cancel();
    _lockoutTimer = null;
    if (!mounted) return;
    if (remaining <= Duration.zero) {
      setState(() => _lockoutEnds = null);
      return;
    }
    setState(() => _lockoutEnds = DateTime.now().add(remaining));
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (lockoutSeconds == 0) {
          timer.cancel();
          _lockoutEnds = null;
        }
      });
    });
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }
}
