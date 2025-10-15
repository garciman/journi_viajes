import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:journi/domain/trip.dart';
import 'package:journi/domain/ports/trip_repository.dart';
import 'package:journi/application/use_cases/use_cases.dart'; // ajusta la ruta real si difiere
import 'package:journi/domain/trip_queries.dart'; // requerido por la interfaz del repo

/// Fake in-memory repo to observe calls without external deps.
class FakeTripRepo implements TripRepository {
  int upsertCalls = 0;
  Trip? lastUpserted;
  Result<Trip>? upsertResultOverride;

  @override
  Future<Result<Trip>> upsert(Trip trip) async {
    upsertCalls++;
    lastUpserted = trip;
    // By default, mimic a successful persistence returning the same entity.
    return upsertResultOverride ?? Ok(trip);
  }

  // The following members aren't used by these tests; keep them simple.
  @override
  Future<Result<void>> deleteById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Result<Trip?>> findById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Trip>>> list({TripPhase? phase}) {
    throw UnimplementedError();
  }

  @override
  Stream<List<Trip>> watchAll({TripPhase? phase}) {
    // Safe empty stream for interface completeness.
    return const Stream<List<Trip>>.empty();
  }
}

void main() {
  group('CreateTripUseCase', () {
    late FakeTripRepo repo;
    late CreateTripUseCase useCase;

    setUp(() {
      repo = FakeTripRepo();
      useCase = CreateTripUseCase(repo);
    });

    test('falla si el título está vacío (no llama al repo)', () async {
      final cmd = CreateTripCommand(id: 't1', title: '   ');
      final res = await useCase.call(cmd);
      expect(res, isA<Err<Trip>>());
      expect(repo.upsertCalls, 0);
    });

    test('crea y persiste un Trip válido, normalizando fechas a UTC', () async {
      final nowBefore = DateTime.now().toUtc();

      final localStart = DateTime(2024, 5, 1, 12, 0); // local
      final localEnd = DateTime(2024, 5, 10, 18, 30); // local

      final cmd = CreateTripCommand(
        id: 't2',
        title: '  Eurotrip  ', // con espacios para verificar trim()
        description: 'desc',
        coverImage: 'img.png',
        startDate: localStart,
        endDate: localEnd,
      );

      final res = await useCase.call(cmd);
      final nowAfter = DateTime.now().toUtc();

      expect(res, isA<Ok<Trip>>());
      final trip = (res as Ok<Trip>).value;

      // Se llamó al repo exactamente una vez con el trip creado
      expect(repo.upsertCalls, 1);
      expect(repo.lastUpserted, isNotNull);

      // title se trimea y respeta el límite en create()
      expect(trip.title, 'Eurotrip');

      // createdAt/updatedAt están en ventana [nowBefore, nowAfter]
      bool inWindow(DateTime d) =>
          !d.isBefore(nowBefore) && !d.isAfter(nowAfter);
      expect(inWindow(trip.createdAt), isTrue);
      expect(inWindow(trip.updatedAt), isTrue);

      // En la creación, createdAt == updatedAt
      expect(trip.updatedAt.isAtSameMomentAs(trip.createdAt), isTrue);

      // start/end quedaron normalizados a UTC
      expect(trip.startDate!.isUtc, isTrue);
      expect(trip.endDate!.isUtc, isTrue);
      expect(
        trip.startDate!.isAtSameMomentAs(localStart.toUtc()),
        isTrue,
      );
      expect(
        trip.endDate!.isAtSameMomentAs(localEnd.toUtc()),
        isTrue,
      );
    });

    test('propaga un Err del repositorio en la persistencia', () async {
      repo.upsertResultOverride =
          Err<Trip>([ValidationError('fallo persistencia')]);

      final cmd = CreateTripCommand(id: 't3', title: 'Título válido');
      final res = await useCase.call(cmd);

      expect(res, isA<Err<Trip>>());
      expect(repo.upsertCalls, 1);
    });
  });

  group('UpdateTripTitleUseCase', () {
    late FakeTripRepo repo;
    late UpdateTripTitleUseCase useCase;
    late Trip baseTrip;

    setUp(() {
      repo = FakeTripRepo();
      useCase = UpdateTripTitleUseCase(repo);

      final created = Trip.create(
        id: 'b1',
        title: 'Base',
        description: 'd',
        coverImage: 'c.png',
        startDate: DateTime.utc(2024, 1, 1),
        endDate: DateTime.utc(2024, 1, 3),
        createdAt: DateTime.utc(2024, 1, 1, 8, 0),
        updatedAt: DateTime.utc(2024, 1, 1, 8, 0),
      );
      baseTrip = (created as Ok<Trip>).value;
    });

    test('falla si el nuevo título es inválido (no llama al repo)', () async {
      final res = await useCase.call(baseTrip, '   ');
      expect(res, isA<Err<Trip>>());
      expect(repo.upsertCalls, 0);
    });

    test('actualiza título y updatedAt, preserva id/createdAt', () async {
      final prevUpdated = baseTrip.updatedAt;
      final nowBefore = DateTime.now().toUtc();

      final res = await useCase.call(baseTrip, 'Road Trip');
      final nowAfter = DateTime.now().toUtc();

      expect(res, isA<Ok<Trip>>());
      final updated = (res as Ok<Trip>).value;

      // repo fue llamado con el Trip actualizado
      expect(repo.upsertCalls, 1);
      expect(repo.lastUpserted!.title, 'Road Trip');

      // id y createdAt se preservan
      expect(updated.id, baseTrip.id);
      expect(updated.createdAt.isAtSameMomentAs(baseTrip.createdAt), isTrue);

      // updatedAt avanza y está dentro de [nowBefore, nowAfter]
      expect(updated.updatedAt.isAfter(prevUpdated), isTrue);
      bool inWindow(DateTime d) =>
          !d.isBefore(nowBefore) && !d.isAfter(nowAfter);
      expect(inWindow(updated.updatedAt), isTrue);
    });

    test('propaga Err del repositorio al persistir', () async {
      repo.upsertResultOverride =
          Err<Trip>([ValidationError('db caído')]);

      final res = await useCase.call(baseTrip, 'Nuevo título');
      expect(res, isA<Err<Trip>>());
      expect(repo.upsertCalls, 1);
    });
  });
}
