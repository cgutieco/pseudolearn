import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/platform/platform_database_factory.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('PlatformDatabaseFactory', () {
    test('can be invoked safely with default parameters', () {
      expect(initializePlatformDatabaseFactory, returnsNormally);
    });

    test('initializes FFI database factory when forceFfi is true', () async {
      initializePlatformDatabaseFactory(forceFfi: true);
      expect(databaseFactory, equals(databaseFactoryFfi));

      final db = await databaseFactory.openDatabase(inMemoryDatabasePath);
      expect(db.isOpen, isTrue);
      await db.close();
    });

    test('does not reconfigure factory when forceFfi is false', () {
      initializePlatformDatabaseFactory(forceFfi: true);
      final current = databaseFactory;
      initializePlatformDatabaseFactory(forceFfi: false);
      expect(databaseFactory, equals(current));
    });
  });
}
