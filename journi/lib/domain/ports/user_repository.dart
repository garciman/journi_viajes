import 'package:journi/application/shared/result.dart';
import 'package:journi/domain/user.dart';

abstract class UserRepository {
  Future<Result<User>> upsert(User user);
  Future<Result<User?>> findById(String id);
  Future<Result<User?>> findByEmail(String email);
  Future<Result<Unit>> deleteById(String id);
  Stream<List<User>> watchAll();
}
