class Viaje{
  final String titulo;
  final DateTime fecha_ini;
  final DateTime fecha_fin;

  const Viaje({
    required this.titulo,
    required this.fecha_ini,
    required this.fecha_fin
  });

  // Para más tarde...

  /*
  factory Viaje.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('titulo') &&
        json.containsKey('fecha_ini') &&
        json.containsKey('fecha_fin') {

        return Viaje(
          titulo: json['titulo'] as String,
          fecha_ini: json['fecha_ini'] as String,
          fecha_fin: json['fecha_fin'] as String,
        );
      } else {
        throw const FormatException('Failed to load viaje.');
      }
  }
  */
}