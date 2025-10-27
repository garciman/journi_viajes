import 'package:flutter_test/flutter_test.dart';
import 'package:journi/domain/entry.dart';

void main() {
  group('Entry.create validations', () {
    test('crea NOTE válida (normaliza texto y tags, fechas UTC)', () {
      final now = DateTime.utc(2025, 1, 1, 12);
      final res = Entry.create(
        id: ' e1 ',
        tripId: ' t1 ',
        type: EntryType.note,
        text: '  hola  ',
        tags: ['  food ', 'food', '  '],
        createdAt: now,
        updatedAt: now,
      );
      expect(res.isOk, isTrue);
      final e = res.asOk().value;
      expect(e.id, 'e1');
      expect(e.tripId, 't1');
      expect(e.text, 'hola');
      expect(e.createdAt.isUtc, isTrue);
      expect(e.updatedAt.isUtc, isTrue);
      expect(e.tags, unorderedEquals(['food']));
    });

    test('crea PHOTO válida (requiere mediaUri)', () {
      final now = DateTime.utc(2025, 1, 1, 12);
      final res = Entry.create(
        id: 'e2',
        tripId: 't1',
        type: EntryType.photo,
        mediaUri: '/tmp/pic.jpg',
        createdAt: now,
        updatedAt: now,
      );
      expect(res.isOk, isTrue);
    });

    test('falla si NOTE sin texto', () {
      final now = DateTime.utc(2025, 1, 1, 12);
      final res = Entry.create(
        id: 'e3',
        tripId: 't1',
        type: EntryType.note,
        createdAt: now,
        updatedAt: now,
      );
      expect(res.isErr, isTrue);
    });

    test('falla si PHOTO sin mediaUri', () {
      final now = DateTime.utc(2025, 1, 1, 12);
      final res = Entry.create(
        id: 'e4',
        tripId: 't1',
        type: EntryType.photo,
        createdAt: now,
        updatedAt: now,
      );
      expect(res.isErr, isTrue);
    });

    test('falla si coordenadas fuera de rango', () {
      final now = DateTime.utc(2025, 1, 1, 12);
      final res = Entry.create(
        id: 'e5',
        tripId: 't1',
        type: EntryType.note,
        text: 'hola',
        location: const EntryLocation(lat: 190, lon: 500),
        createdAt: now,
        updatedAt: now,
      );
      expect(res.isErr, isTrue);
    });

    test('falla si updatedAt < createdAt', () {
      final created = DateTime.utc(2025, 1, 1, 12);
      final updated = created.subtract(const Duration(seconds: 1));
      final res = Entry.create(
        id: 'e6',
        tripId: 't1',
        type: EntryType.note,
        text: 'hola',
        createdAt: created,
        updatedAt: updated,
      );
      expect(res.isErr, isTrue);
    });
  });

  group('Entry.copyValidated', () {
    test('actualiza texto y updatedAt', () {
      final now = DateTime.utc(2025, 1, 1, 12);
      final res = Entry.create(
        id: 'e1',
        tripId: 't1',
        type: EntryType.note,
        text: 'hola',
        createdAt: now,
        updatedAt: now,
      ).asOk().value;

      final copy = res.copyValidated(text: 'adiós').asOk().value;
      expect(copy.text, 'adiós');
      expect(copy.updatedAt.isAfter(res.updatedAt), isTrue);
      expect(copy.createdAt, res.createdAt);
    });
  });
}