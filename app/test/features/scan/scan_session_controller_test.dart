import 'package:docxan/core/imaging/crop_quad.dart';
import 'package:docxan/features/scan/presentation/controllers/scan_session_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('ScanSessionController cuenta y rota páginas', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(scanSessionProvider.notifier);

    expect(container.read(scanSessionProvider).pageCount, 0);

    controller.addPage('/tmp/a.jpg');
    controller.addPage('/tmp/b.jpg');
    expect(container.read(scanSessionProvider).pageCount, 2);
    expect(container.read(scanSessionProvider).currentIndex, 1);

    controller.rotateCurrent();
    expect(container.read(scanSessionProvider).currentPage?.rotationTurns, 1);

    controller.setFilter(ScanFilterKind.bw);
    expect(
      container.read(scanSessionProvider).currentPage?.filter,
      ScanFilterKind.bw,
    );

    controller.removePageAt(0);
    expect(container.read(scanSessionProvider).pageCount, 1);

    controller.addPage('/tmp/c.jpg');
    controller.addPage('/tmp/d.jpg');
    controller.setCurrentIndex(1);
    controller.beginRetake();
    controller.addPage('/tmp/retake.jpg');
    expect(container.read(scanSessionProvider).currentPage?.path, '/tmp/retake.jpg');
    expect(container.read(scanSessionProvider).retaking, isFalse);

    controller.movePage(0, 2);
    expect(
      container.read(scanSessionProvider).pages.map((page) => page.path).toList(),
      ['/tmp/retake.jpg', '/tmp/d.jpg', '/tmp/b.jpg'],
    );

    controller.beginRetake();
    controller.cancelRetake();
    expect(container.read(scanSessionProvider).retaking, isFalse);

    controller.clear();
    expect(container.read(scanSessionProvider).pageCount, 0);
  });
}
