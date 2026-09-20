import 'package:docxan/app/flavor.dart';
import 'package:flutter/foundation.dart';

abstract final class AppLogger {
  static FlavorConfig? _flavor;

  static void init(FlavorConfig flavor) {
    _flavor = flavor;
  }

  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('[docxan][${_flavor?.flavor.name ?? 'app'}] $message');
    }
  }
}
