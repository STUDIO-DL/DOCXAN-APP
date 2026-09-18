import 'package:doxan/features/scan/presentation/states/scan_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScanController extends Notifier<ScanState> {
  @override
  ScanState build() => const ScanState();
}

final scanControllerProvider = NotifierProvider<ScanController, ScanState>(
  ScanController.new,
);
