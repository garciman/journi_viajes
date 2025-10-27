import 'dart:async';
import 'package:journi/domain/entry.dart';
import 'package:journi/domain/ports/entry_repository.dart';
import 'package:journi/application/shared/result.dart';

/// Implementación en memoria, ordenando por createdAt DESC.
class InMemoryEntryRepository implements EntryRepository {
  final Map<String, Entry> _db = {};
  final StreamController<void> _changes = StreamController.broadcast();

  InMemoryEntryRepository();

  List<Entry> _snapshot({String? tripId, EntryType? type}) {
    final items = _db.values.where((e) {
      final okTrip = tripId == null || e.tripId == tripId;
      final okType = type == null || e.type == type;
      return okTrip && okType;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(items);
  }

  void _emit() {
    if (!_changes.isClosed) _changes.add(null);
  }

  @override
  Future<Result<Entry>> upsert(Entry entry) async {
    _db[entry.id] = entry;
    _emit();
    return Ok(entry);
  }

  @override
  Future<Result<void>> deleteById(String id) async {
    _db.remove(id);
    _emit();
    return Ok(unit);
  }

  @override
  Future<Result<Entry?>> findById(String id) async {
    return Ok(_db[id]);
  }

  @override
  Future<Result<List<Entry>>> list({String? tripId, EntryType? type}) async {
    return Ok(_snapshot(tripId: tripId, type: type));
  }

  @override
  Stream<List<Entry>> watchAll({String? tripId, EntryType? type}) {
    // Mapeamos el stream de cambios a una instantánea filtrada en cada emisión.
    return _changes.stream.map((_) => _snapshot(tripId: tripId, type: type)).startWith(_snapshot(tripId: tripId, type: type));
  }

  void dispose() {
    _changes.close();
  }
}

/// Extensión utilitaria para emitir el valor inicial en watchAll.
extension _StartWith<T> on Stream<T> {
  Stream<T> startWith(T initial) async* {
    yield initial;
    yield* this;
  }
}