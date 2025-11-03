import 'package:journi/application/shared/result.dart';
import 'package:journi/domain/entry.dart';

/// Puerto de acceso a datos para Entries.
abstract class EntryRepository {
  Future<Result<Entry>> upsert(Entry entry);
  Future<Result<Unit>> deleteById(String id);
  Future<Result<Entry?>> findById(String id);

  /// Lista por viaje opcionalmente filtrando por tipo. Orden recomendado: createdAt DESC.
  Future<Result<List<Entry>>> list({String? tripId, EntryType? type});

  /// Observación de cambios. Cada emisión respeta los filtros dados.
  Stream<List<Entry>> watchAll({String? tripId, EntryType? type});
}