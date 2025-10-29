import 'dart:async';
import 'package:journi/application/use_cases/entry_use_cases.dart';
import 'package:journi/domain/entry.dart';
import 'package:journi/application/entry_service.dart';
import 'package:journi/application/shared/result.dart';
import 'package:journi/domain/ports/entry_repository.dart';
import 'package:journi/domain/entry.dart';

class EntryRepositoryMock implements EntryRepository {
  final Map<String, Entry> _entries = {};

  @override
  Future<Result<void>> save(Entry entry) async {
    _entries[entry.id] = entry;
    return Ok(null);
  }

  @override
  Future<Result<Entry?>> findById(String id) async {
    return Ok(_entries[id]);
  }

  List<Entry> listByTrip(String tripId, {EntryType? type}) {
    return _entries.values
        .where((e) => e.tripId == tripId && (type == null || e.type == type))
        .toList();
  }

  @override
  Future<Result<void>> deleteById(String id) {
    // TODO: implement deleteById
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Entry>>> list({String? tripId, EntryType? type}) {
    // TODO: implement list
    throw UnimplementedError();
  }

  @override
  Future<Result<Entry>> upsert(Entry entry) {
    // TODO: implement upsert
    throw UnimplementedError();
  }

  @override
  Stream<List<Entry>> watchAll({String? tripId, EntryType? type}) {
    // TODO: implement watchAll
    throw UnimplementedError();
  }
}

class EntryServiceMock implements EntryService {
  final EntryRepositoryMock repo;

  EntryServiceMock(this.repo);

  @override
  Future<Result<Entry>> create(CreateEntryCommand cmd) async {
    final entry = Entry.create(
      id: cmd.id,
      tripId: cmd.tripId,
      type: cmd.type,

      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await repo.save(entry as Entry);
    return Ok(entry as Entry);
  }

  @override
  Future<Result<void>> deleteById(String id) async {
    repo._entries.remove(id);
    return Ok(null);
  }

  @override
  Future<Result<Entry?>> getById(String id) async {
    return await repo.findById(id);
  }

  @override
  Future<Result<List<Entry>>> listByTrip(String tripId, {EntryType? type}) async {
    final entries = repo.listByTrip(tripId, type: type);
    return Ok(entries);
  }

  @override
  Stream<List<Entry>> watchByTrip(String tripId, {EntryType? type}) {
    final entries = repo.listByTrip(tripId, type: type);
    return Stream.value(entries);
  }
}
