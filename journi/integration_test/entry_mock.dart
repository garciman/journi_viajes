import 'dart:async';
import 'package:journi/application/shared/result.dart';
import 'package:journi/domain/entry.dart';
import 'package:journi/domain/ports/entry_repository.dart';
import 'package:journi/application/entry_service.dart';
import 'package:journi/application/use_cases/entry_use_cases.dart';

class EntryRepositoryMock implements EntryRepository {
  final Map<String, Entry> _db = {};
  final _changes = StreamController<void>.broadcast();

  List<Entry> _snapshot({String? tripId, EntryType? type}) {
    final items = _db.values.where((e) {
      final byTrip = tripId == null || e.tripId == tripId;
      final byType = type == null || e.type == type;
      return byTrip && byType;
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
  Future<Result<Unit>> deleteById(String id) async {
    _db.remove(id);
    _emit();
    return const Ok(unit);
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
    final out = StreamController<List<Entry>>.broadcast();
    StreamSubscription<void>? sub;

    void emitNow() => out.add(_snapshot(tripId: tripId, type: type));

    out.onListen = () {
      emitNow();
      sub = _changes.stream.listen((_) => emitNow());
    };
    out.onCancel = () async {
      await sub?.cancel();
      sub = null;
    };

    return out.stream;
  }

  void dispose() {
    _changes.close();
  }
}

class EntryServiceMock implements EntryService {
  final EntryRepository repo;
  EntryServiceMock(this.repo);

  @override
  Future<Result<Entry>> create(CreateEntryCommand cmd) async {
    final now = DateTime.now().toUtc();
    final res = Entry.create(
      id: cmd.id,
      tripId: cmd.tripId,
      type: cmd.type,
      text: cmd.text,
      mediaUri: cmd.mediaUri,
      location: cmd.location,
      tags: cmd.tags,
      createdAt: now,
      updatedAt: now,
    );
    if (res.isErr) return Err(res.asErr().errors);
    return repo.upsert(res.asOk().value);
  }

  @override
  Future<Result<Unit>> deleteById(String id) => repo.deleteById(id);

  @override
  Future<Result<Entry?>> getById(String id) => repo.findById(id);

  @override
  Future<Result<List<Entry>>> listByTrip(String tripId, {EntryType? type}) {
    return repo.list(tripId: tripId, type: type);
  }

  @override
  Stream<List<Entry>> watchByTrip(String tripId, {EntryType? type}) {
    return repo.watchAll(tripId: tripId, type: type);
  }
}
