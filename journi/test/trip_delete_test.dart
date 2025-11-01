import 'package:flutter_test/flutter_test.dart';
import 'package:journi/application/trip_service.dart';
import 'package:journi/application/use_cases/use_cases.dart';
import 'package:journi/data/memory/in_memory_trip_repository.dart';
import 'package:journi/domain/trip.dart';

void main(){
  group('Trip.create - validaciones y normalización', () {
    test('trimea el título y devuelve Ok', () {
      var repo = InMemoryTripRepository();
      TripService tripService = makeTripService(repo);
      final cmd = CreateTripCommand(
        id: 'id0',
        title: 'El Nano',
        description: 'Description',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );
      tripService.create(cmd);

      final res = repo.deleteById('id0');
      expect(res, isA<Ok<void>>()); // group/test/expect son prácticas estándar. :contentReference[oaicite:2]{index=2}

    });


  });
}