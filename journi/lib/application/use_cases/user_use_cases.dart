import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart' show sha256; // pub.dev/crypto
import 'package:journi/application/shared/result.dart';
import 'package:journi/domain/user.dart';
import 'package:journi/domain/ports/user_repository.dart';

String _randomSaltB64([int length = 16]) {
  final r = Random.secure();
  final bytes = List<int>.generate(length, (_) => r.nextInt(256));
  return base64Url.encode(bytes);
}

String _hashPassword(String password, String saltB64) {
  final data = utf8.encode('$saltB64:$password');
  return sha256.convert(data).toString(); // digest hex
}

class RegisterUserCommand {
  final String id;
  final String name;
  final String lastName;
  final String email;
  final String password;
  const RegisterUserCommand({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.password,
  });
}

class RegisterUserUseCase {
  final UserRepository repo;
  RegisterUserUseCase(this.repo);

  Future<Result<User>> call(RegisterUserCommand cmd) async {
    final now = DateTime.now().toUtc();
    final salt = _randomSaltB64();
    final hash = _hashPassword(cmd.password, salt);

    final res = User.create(
      id: cmd.id,
      name: cmd.name,
      lastName: cmd.lastName,
      email: cmd.email.toLowerCase(),
      passwordHash: hash,
      passwordSalt: salt,
      createdAt: now,
      updatedAt: now,
    );
    if (res is Err<User>) return res;

    return repo.upsert(res.asOk().value);
  }
}

class AuthenticateUserCommand {
  final String email;
  final String password;
  const AuthenticateUserCommand({required this.email, required this.password});
}

class AuthenticateUserUseCase {
  final UserRepository repo;
  AuthenticateUserUseCase(this.repo);

  Future<Result<User>> call(AuthenticateUserCommand cmd) async {
    final found = await repo.findByEmail(cmd.email.toLowerCase());
    if (found is Err<User?>) return Err<User>(found.errorsOrEmpty);

    final user = found.asOk().value;
    if (user == null) {
      return Err<User>([const ValidationError('Credenciales inválidas')]);
    }
    final hash = _hashPassword(cmd.password, user.passwordSalt);
    if (hash != user.passwordHash) {
      return Err<User>([const ValidationError('Credenciales inválidas')]);
    }
    return Ok(user);
  }
}

class GetUserByIdUseCase {
  final UserRepository repo;
  GetUserByIdUseCase(this.repo);
  Future<Result<User?>> call(String id) => repo.findById(id);
}

class DeleteUserUseCase {
  final UserRepository repo;
  DeleteUserUseCase(this.repo);
  Future<Result<Unit>> call(String id) => repo.deleteById(id);
}

class ListUsersUseCase {
  final UserRepository repo;
  ListUsersUseCase(this.repo);
  Stream<List<User>> call() => repo.watchAll();
}
