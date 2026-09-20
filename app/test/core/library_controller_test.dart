import 'package:docxan/core/library/library_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('createFolder añade una carpeta y rechaza duplicados', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await Future<void>.delayed(Duration.zero);

    final controller = container.read(libraryProvider.notifier);
    expect(controller.createFolder('  Personal  '), FolderCreateResult.created);
    expect(container.read(libraryProvider).folders.single.name, 'Personal');
    expect(controller.createFolder('personal'), FolderCreateResult.duplicate);
    expect(controller.createFolder('   '), FolderCreateResult.emptyName);
  });
}
