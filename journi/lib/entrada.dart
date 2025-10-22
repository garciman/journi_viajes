// lib/entrada.dart
import 'package:flutter/foundation.dart';

@immutable
class Entrada {
  final String id;
  final int tripIndex; // índice del viaje al que pertenece (mock simple)
  final String titulo;
  final String texto;
  final DateTime fecha;
  final List<String> fotos; // rutas/urls (por ahora vacío)

  const Entrada({
    required this.id,
    required this.tripIndex,
    required this.titulo,
    required this.texto,
    required this.fecha,
    this.fotos = const [],
  });

  Entrada copyWith({
    String? id,
    int? tripIndex,
    String? titulo,
    String? texto,
    DateTime? fecha,
    List<String>? fotos,
  }) {
    return Entrada(
      id: id ?? this.id,
      tripIndex: tripIndex ?? this.tripIndex,
      titulo: titulo ?? this.titulo,
      texto: texto ?? this.texto,
      fecha: fecha ?? this.fecha,
      fotos: fotos ?? this.fotos,
    );
  }
}
