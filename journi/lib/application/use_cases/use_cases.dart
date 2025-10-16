import 'package:journi/domain/trip.dart';
import 'package:journi/domain/trip_extensions.dart';
import 'package:journi/domain/ports/trip_repository.dart';

class CreateTripCommand {
  final String id;
  final String title;
  final String? description;
  final String? coverImage;
  final DateTime? startDate;
  final DateTime? endDate;

  CreateTripCommand({
    required this.id,
    required this.title,
    this.description,
    this.coverImage,
    this.startDate,
    this.endDate,
  });
}

class CreateTripUseCase {
  final TripRepository repo;
  CreateTripUseCase(this.repo);

  Future<Result<Trip>> call(CreateTripCommand cmd) async {
    final now = DateTime.now().toUtc();
    final res = Trip.create(
      id: cmd.id,
      title: cmd.title,
      description: cmd.description,
      coverImage: cmd.coverImage,
      startDate: cmd.startDate,
      endDate: cmd.endDate,
      createdAt: now,
      updatedAt: now,
    );
    if (res is Err<Trip>) return res;
    return repo.upsert((res as Ok<Trip>).value);
  }
}

class UpdateTripTitleUseCase {
  final TripRepository repo;
  UpdateTripTitleUseCase(this.repo);

  Future<Result<Trip>> call(Trip current, String newTitle) async {
    final res = current.withTitle(newTitle);
    if (res is Err<Trip>) return res;
    final ok = res as Ok<Trip>;
    final updated = ok.value.copyValidated(updatedAt: DateTime.now().toUtc());
    return repo.upsert((updated as Ok<Trip>).value);
  }
}