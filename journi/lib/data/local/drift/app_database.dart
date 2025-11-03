import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// El enum y tipos de dominio que referencian los converters/tabl
import 'package:journi/domain/entry.dart';

part 'app_database.g.dart';   // generado por drift
part 'converters.dart';       // converters formarán parte de esta librería
part 'tables.dart';           // tablas formarán parte de esta librería

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
