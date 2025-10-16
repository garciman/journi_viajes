// Ajusta imports según tu estructura de proyecto.
import 'package:flutter_test/flutter_test.dart';
import 'package:journi/domain/trip.dart';
import 'package:journi/domain/trip_queries.dart';

Trip _okTrip(Result<Trip> r) {
  expect(r, isA<Ok<Trip>>());
  return (r as Ok<Trip>).value;
}

void main() {
  group('TripQueries', () {
    test('hasDates true/false según presencia de start/end', () {
      final t1 = _okTrip(Trip.create(id: 'a', title: 'x', createdAt: DateTime.now(), updatedAt: DateTime.now()));
      expect(t1.hasDates, isFalse);
      final t2 = _okTrip(Trip.create(id: 'b', title: 'y', startDate: DateTime.utc(2025,1,1), createdAt: DateTime.now(), updatedAt: DateTime.now()));
      expect(t2.hasDates, isTrue);
      final t3 = _okTrip(Trip.create(id: 'c', title: 'z', endDate: DateTime.utc(2025,1,1), createdAt: DateTime.now(), updatedAt: DateTime.now()));
      expect(t3.hasDates, isTrue);
    });

    test('phase: undated / planned / ongoing / finished', () {
      final now = DateTime.now().toUtc();
      final createdAt = now;
      final updatedAt = now;

      final undated = _okTrip(Trip.create(id:'u',title:'u',createdAt:createdAt,updatedAt:updatedAt));
      expect(undated.phase, TripPhase.undated);

      final planned = _okTrip(Trip.create(
        id:'p', title:'p',
        startDate: now.add(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 5)),
        createdAt: createdAt, updatedAt: updatedAt,
      ));
      expect(planned.phase, TripPhase.planned);

      final finished = _okTrip(Trip.create(
        id:'f', title:'f',
        startDate: now.subtract(const Duration(days: 5)),
        endDate: now.subtract(const Duration(days: 1)),
        createdAt: createdAt, updatedAt: updatedAt,
      ));
      expect(finished.phase, TripPhase.finished);

      final ongoing = _okTrip(Trip.create(
        id:'o', title:'o',
        startDate: now.subtract(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 1)),
        createdAt: createdAt, updatedAt: updatedAt,
      ));
      expect(ongoing.phase, TripPhase.ongoing);
    });

    test('durationDays: null si falta fecha; ceil sobre horas', () {
      // difference() devuelve un Duration; usamos sus inDays/inHours para el cálculo. :contentReference[oaicite:4]{index=4}
      final createdAt = DateTime.utc(2025,1,1);
      final updatedAt = DateTime.utc(2025,1,1);

      final tNull = _okTrip(Trip.create(id:'n',title:'n',startDate: DateTime.utc(2025,1,1), createdAt: createdAt, updatedAt: updatedAt));
      expect(tNull.durationDays, isNull);

      final exactDays = _okTrip(Trip.create(
        id:'e',title:'e',
        startDate: DateTime.utc(2025,1,1,0,0),
        endDate:   DateTime.utc(2025,1,3,0,0),
        createdAt: createdAt, updatedAt: updatedAt,
      ));
      expect(exactDays.durationDays, 2);

      final withHours = _okTrip(Trip.create(
        id:'h',title:'h',
        startDate: DateTime.utc(2025,1,1,10,0),
        endDate:   DateTime.utc(2025,1,2,12,0),
        createdAt: createdAt, updatedAt: updatedAt,
      ));
      expect(withHours.durationDays, 2); // ceil(>24h) = 2
    });

    test('overlapsWith: intersección inclusiva en extremos', () {
      final ca = DateTime.utc(2025,1,1);
      final ua = DateTime.utc(2025,1,1);
      Trip mk(DateTime s, DateTime e) => _okTrip(Trip.create(
        id: '${s.millisecondsSinceEpoch}-${e.millisecondsSinceEpoch}',
        title: 't', startDate: s, endDate: e, createdAt: ca, updatedAt: ua,
      ));

      final a = mk(DateTime.utc(2025,1,1), DateTime.utc(2025,1,2));
      final b = mk(DateTime.utc(2025,1,2), DateTime.utc(2025,1,3));
      final c = mk(DateTime.utc(2025,1,3), DateTime.utc(2025,1,4));

      expect(a.overlapsWith(b), isTrue);  // [1,2] con [2,3] solapan
      expect(a.overlapsWith(c), isFalse); // [1,2] con [3,4] no
      // Si falta rango completo en alguno → false
      final d = _okTrip(Trip.create(id:'d',title:'d',startDate: DateTime.utc(2025,1,1),createdAt:ca,updatedAt:ua));
      expect(a.overlapsWith(d), isFalse);
    });

    test('occursOn: cubre el día UTC completo [00:00, 23:59:59.999999]', () {
      final ca = DateTime.utc(2025,1,1);
      final ua = DateTime.utc(2025,1,1);
      final t = _okTrip(Trip.create(
        id:'occ', title:'occ',
        startDate: DateTime.utc(2025,1,1,23,30),
        endDate:   DateTime.utc(2025,1,2,0,15),
        createdAt: ca, updatedAt: ua,
      ));
      expect(t.occursOn(DateTime.utc(2025,1,1)), isTrue);
      expect(t.occursOn(DateTime.utc(2025,1,2)), isTrue);
      expect(t.occursOn(DateTime.utc(2025,1,3)), isFalse);
    });
  });
}
