import 'dart:async';
import 'package:journi/application/shared/result.dart';
import 'package:journi/domain/trip.dart';
import 'package:journi/domain/trip_queries.dart';
import 'package:journi/domain/ports/trip_repository.dart';

/// Repositorio en memoria (mínimo viable) para desarrollo sin BD.
class InMemoryTripRepository implements TripRepository {
  final Map<String, Trip> _store;
  final _controller = StreamController<List<Trip>>.broadcast();

  InMemoryTripRepository({Iterable<Trip>? seed})
      : _store = {for (final t in (seed ?? const <Trip>[])) t.id: t} {
    _emit();
  }

  void _emit() {
    final items = _store.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _controller.add(items);
  }

  List<Trip> _filtered(TripPhase? phase) {
    var items = _store.values.toList();
    if (phase != null) {
      items = items.where((t) => t.phase == phase).toList();
    }
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<Result<Trip>> upsert(Trip trip) async {
    // Revalida vía dominio por si alguien construyó un Trip no-normalizado
    final res = Trip.create(
      id: trip.id,
      title: trip.title,
      description: trip.description,
      coverImage: trip.coverImage,
      startDate: trip.startDate,
      endDate: trip.endDate,
      createdAt: trip.createdAt,
      updatedAt: trip.updatedAt,
    );
    if (res is Err<Trip>) return res;
    final ok = res as Ok<Trip>;
    _store[ok.value.id] = ok.value;
    _emit();
    return ok;
  }

  @override
  Future<Result<Trip?>> findById(String id) async => Ok(_store[id]);

  @override
  Future<Result<List<Trip>>> list({TripPhase? phase}) async =>
      Ok(_filtered(phase));

  @override
  Stream<List<Trip>> watchAll({TripPhase? phase}) => phase == null
      ? _controller.stream
      : _controller.stream.map((_) => _filtered(phase));

  @override
  Future<Result<void>> deleteById(String id) async {
    _store.remove(id);
    _emit();
    return const Ok(null);
  }

  /// Limpia recursos del stream cuando ya no se use (por ejemplo en tests).
  Future<void> dispose() async => _controller.close();
}
