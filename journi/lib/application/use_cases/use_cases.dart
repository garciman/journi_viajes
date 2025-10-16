import 'package:journi/domain/trip.dart';
import 'package:journi/domain/trip_extensions.dart';
import 'package:journi/domain/ports/trip_repository.dart';
import 'package:journi/domain/trip_queries.dart';

class CreateTripCommand {
  final String id;
  final String title;
  final String? description;
  final String? coverImage;
  final DateTime? startDate;
  final DateTime? endDate;

  CreateTripCommand({
    required this.id,
    required this.title,
    this.description,
    this.coverImage,
    this.startDate,
    this.endDate,
  });
}

class CreateTripUseCase {
  final TripRepository repo;
  CreateTripUseCase(this.repo);

  Future<Result<Trip>> call(CreateTripCommand cmd) async {
    final now = DateTime.now().toUtc();
    final res = Trip.create(
      id: cmd.id,
      title: cmd.title,
      description: cmd.description,
      coverImage: cmd.coverImage,
      startDate: cmd.startDate,
      endDate: cmd.endDate,
      createdAt: now,
      updatedAt: now,
    );
    if (res is Err<Trip>) return res;
    return repo.upsert((res as Ok<Trip>).value);
  }
}

class UpdateTripTitleUseCase {
  final TripRepository repo;
  UpdateTripTitleUseCase(this.repo);

  Future<Result<Trip>> call(Trip current, String newTitle) async {
    final res = current.withTitle(newTitle);
    if (res is Err<Trip>) return res;
    final ok = res as Ok<Trip>;
    final updated = ok.value.copyValidated(updatedAt: DateTime.now().toUtc());
    return repo.upsert((updated as Ok<Trip>).value);
  }

  
}

/// Lista trips (opcionalmente filtrados por fase).
class ListTripsUseCase {
  final TripRepository repo;
  ListTripsUseCase(this.repo);

  /// Devuelve todos los trips, o solo los de una fase concreta.
  /// Delegamos el orden a la implementación del repo (en memoria: createdAt DESC).
  Future<Result<List<Trip>>> call({TripPhase? phase}) {
    return repo.list(phase: phase);
  }
}

/// Observa trips en tiempo real (ideal para usar con StreamBuilder en Flutter).
class WatchTripsUseCase {
  final TripRepository repo;
  WatchTripsUseCase(this.repo);

  /// Emite cambios en la colección (filtrable por fase).
  Stream<List<Trip>> call({TripPhase? phase}) => repo.watchAll(phase: phase);
}

/// Listado por día concreto (UTC). Útil para vistas de calendario.
/// Usa Trip.occursOn(dayUtc) definido en trip_queries.dart.
class ListTripsForDayUseCase {
  final TripRepository repo;
  ListTripsForDayUseCase(this.repo);

  Future<Result<List<Trip>>> call(DateTime dayUtc) async {
    final res = await repo.list();
    if (res is Err<List<Trip>>) return res;
    final items = (res as Ok<List<Trip>>)
        .value
        .where((t) => t.occursOn(dayUtc.toUtc()))
        .toList();
    return Ok(items);
  }
}