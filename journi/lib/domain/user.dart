import 'package:journi/application/shared/result.dart';

class User {
  final String id;        // usaremos email como id para simplificar
  final String name;
  final String lastName;
  final String email;     // siempre lowercase
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  static Result<User> create({
    required String id,
    required String name,
    required String lastName,
    required String email,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    final errs = <ValidationError>[];
    final n = name.trim();
    final ln = lastName.trim();
    final e = email.trim().toLowerCase();

    if (n.isEmpty) errs.add(ValidationError('name no puede estar vacío'));
    if (ln.isEmpty) errs.add(ValidationError('lastName no puede estar vacío'));
    if (!e.contains('@')) errs.add(ValidationError('email no es válido'));

    if (errs.isNotEmpty) return Err(errs);

    return Ok(User(
      id: id.trim(),
      name: n,
      lastName: ln,
      email: e,
      createdAt: createdAt.toUtc(),
      updatedAt: updatedAt.toUtc(),
    ));
  }
}
