class Viaje{
  final String titulo;
  final DateTime fecha_ini;
  final DateTime fecha_fin;
  // final Photo foto;
  // final ¿String? ubicacion;

  const Viaje({
    required this.titulo,
    required this.fecha_ini,
    required this.fecha_fin,
    // required this.foto,
    // required this.ubicacion,
  });

  // Para más tarde...

  /*
  factory Viaje.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('titulo') &&
        json.containsKey('fecha_ini') &&
        json.containsKey('fecha_fin') &&
        json.containsKey('foto') &&
        json.containsKey('ubicacion'){

        return Viaje(
          titulo: json['titulo'] as String,
          fecha_ini: json['fecha_ini'] as String, // esto me puede dar problemas mas tarde
          fecha_fin: json['fecha_fin'] as String, // esto me puede dar problemas mas tarde
          foto: json['fecha_fin'] as uint64,
          ubicacion: json['fecha_fin'] as String,
        );
      } else {
        throw const FormatException('Failed to load viaje.');
      }
  }
  */
}