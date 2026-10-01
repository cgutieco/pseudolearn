import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void initializePlatformDatabaseFactory({bool? forceFfi}) {
  final useFfi = forceFfi ?? (Platform.isWindows || Platform.isLinux);
  if (useFfi) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}
