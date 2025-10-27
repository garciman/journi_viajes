import 'package:journi/application/shared/result.dart';
import 'package:journi/domain/entry.dart';
import 'package:journi/domain/ports/entry_repository.dart';

class CreateEntryCommand {
  final String id;
  final String tripId;
  final EntryType type;
  final String? text;
  final String? mediaUri;
  final EntryLocation? location;
  final List<String> tags;

  const CreateEntryCommand({
    required this.id,
    required this.tripId,
    required this.type,
    this.text,
    this.mediaUri,
    this.location,
    this.tags = const [],
  });
}

class CreateEntryUseCase {
  final EntryRepository repo;
  CreateEntryUseCase(this.repo);

  Future<Result<Entry>> call(CreateEntryCommand cmd) async {
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
    if (res is Err<Entry>) return res;
    return repo.upsert((res as Ok<Entry>).value);
  }
}

class GetEntryByIdUseCase {
  final EntryRepository repo;
  GetEntryByIdUseCase(this.repo);
  Future<Result<Entry?>> call(String id) => repo.findById(id);
}

class DeleteEntryUseCase {
  final EntryRepository repo;
  DeleteEntryUseCase(this.repo);
  Future<Result<void>> call(String id) => repo.deleteById(id);
}

class ListEntriesUseCase {
  final EntryRepository repo;
  ListEntriesUseCase(this.repo);
  Future<Result<List<Entry>>> call({required String tripId, EntryType? type}) {
    return repo.list(tripId: tripId, type: type);
  }
}

class WatchEntriesUseCase {
  final EntryRepository repo;
  WatchEntriesUseCase(this.repo);
  Stream<List<Entry>> call({required String tripId, EntryType? type}) {
    return repo.watchAll(tripId: tripId, type: type);
  }
}
