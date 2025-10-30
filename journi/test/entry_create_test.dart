import 'package:flutter_test/flutter_test.dart';
import 'package:journi/application/shared/result.dart';
import 'package:journi/domain/entry.dart';

void main(){
  group('Trip.create - validaciones y normalización', () {
    test('trimea el título y devuelve Ok', () {
      final res = Entry.create(
        id: 't1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tripId: 'tt1',
        text: 'Mi entrada',
        type: EntryType.note,
      );
      expect(res,
          isA<Ok<Entry>>()); // group/test/expect son prácticas estándar. :contentReference[oaicite:2]{index=2}
      final entry = (res as Ok<Entry>).value;
      expect(entry.text, 'Mi entrada');
    });

    test('title vacío -> Err', () {
      final res = Entry.create(
        id: 't2',
        text: '   ',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tripId: 'tt2',
        type: EntryType.note,
      );
      expect(res, isA<Err<Entry>>());
      
    });
  });
}