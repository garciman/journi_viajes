import 'package:journi/application/trip_service.dart';
import 'package:journi/application/use_cases/use_cases.dart';
import 'package:journi/data/memory/in_memory_trip_repository.dart';
import 'package:journi/domain/trip.dart';
import 'package:journi/domain/trip_queries.dart';

class TripServiceMock implements TripService {
  final InMemoryTripRepository repo;

  TripServiceMock(this.repo);

  @override
  Future<Result<Trip>> create(CreateTripCommand cmd) async {
    // Simula creación exitosa de viaje
    final trip = Trip(
      id: cmd.id,
      title: cmd.title,
      description: cmd.description,
      startDate: cmd.startDate,
      endDate: cmd.endDate,
      createdAt: DateTime.now(),  // obligatorio
      updatedAt: DateTime.now(),
    );
    repo.upsert(trip); // agrega al repo en memoria si quieres
    return Ok(trip);
  }

  @override
  Future<Result<Trip>> patch(UpdateTripCommand cmd) async {
    return Err([ValidationError('No implementado')]);
  }

  @override
  Future<Result<void>> deleteById(String id) async => Ok(null);

  @override
  Future<Result<Trip>> updateTitleById(String id, String newTitle) async {
    final result = await repo.findById(id);

    if (result is Err<Trip?>) {
      return Err(result.errors);
    }

    final trip = (result as Ok<Trip?>).value;

    if (trip == null) {
      return Err([ValidationError('Trip no existe')]);
    }

    // Crear un nuevo Trip con el título actualizado
    final updatedTrip = Trip(
      id: trip.id,
      title: newTitle, // nuevo título
      description: trip.description,
      startDate: trip.startDate,
      endDate: trip.endDate,
      createdAt: trip.createdAt,
      updatedAt: DateTime.now(),
    );

    // Si quieres, guardarlo en el repo
    await repo.upsert(updatedTrip);

    return Ok(updatedTrip);
  }

  @override
  Future<Result<Trip?>> getById(String id) async {
    final trip = repo.findById(id);
    return Ok(trip as Trip?);
  }

  @override
  Future<Result<List<Trip>>> list({TripPhase? phase}) async {
    // repo.list() devuelve List<Trip>
    final trips = repo.list();
    return Ok(trips as List<Trip>); // ✅ Ok envuelve List<Trip> en Result
  }

  @override
  Stream<List<Trip>> watch({TripPhase? phase}) {
    // repo.list() devuelve List<Trip>
    final trips = repo.list();
    return Stream.value(trips as List<Trip>); // ✅ devuelve Stream<List<Trip>>
  }

  @override
  Future<Result<List<Trip>>> listForDayUtc(DateTime dayUtc) async => Ok([]);
}