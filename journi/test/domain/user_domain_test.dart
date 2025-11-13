import 'package:flutter_test/flutter_test.dart';
import 'package:journi/domain/user.dart';

void main() {
  group('User.create', () {
    test('crea user válido', () {
      final now = DateTime.now().toUtc();
      final r = User.create(
        id: 'u1',
        name: 'Ada',
        lastName: 'Lovelace',
        email: 'Ada@Example.COM',
        passwordHash: 'deadbeef',
        passwordSalt: 'salt',
        createdAt: now,
        updatedAt: now.add(const Duration(seconds: 1)),
      );
      expect(r.isOk, isTrue);
      final u = r.asOk().value;
      expect(u.email, equals('ada@example.com')); // normalizado a lowercase
    });

    test('falla con email inválido', () {
      final now = DateTime.now().toUtc();
      final r = User.create(
        id: 'u1',
        name: 'Ada',
        lastName: 'Lovelace',
        email: 'not-an-email',
        passwordHash: 'h',
        passwordSalt: 's',
        createdAt: now,
        updatedAt: now,
      );
      expect(r.isErr, isTrue);
    });

    test('falla si updatedAt < createdAt', () {
      final now = DateTime.now().toUtc();
      final r = User.create(
        id: 'u1',
        name: 'Ada',
        lastName: 'Lovelace',
        email: 'a@b.com',
        passwordHash: 'h',
        passwordSalt: 's',
        createdAt: now,
        updatedAt: now.subtract(const Duration(seconds: 1)),
      );
      expect(r.isErr, isTrue);
    });
  });
}
