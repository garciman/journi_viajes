import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// 👇 Traemos el enum del dominio a ESTA library (para que el .g.dart lo vea)
import 'package:journi/domain/entry.dart';

part 'app_database.g.dart';   // generado por drift
part 'converters.dart';       // <- ahora es "part of"
part 'tables.dart';           // <- ahora es "part of"

@DriftDatabase(tables: [Trips, Entries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openLazy());
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
      );
}

LazyDatabase _openLazy() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'journi.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
