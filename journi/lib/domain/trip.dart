// Un resultado que puede ser un Trip válido o errores
// sealed class = una clase “cerrada” que solo puede tener ciertas subclases conocidas (Ok y Err).
// <T> = el tipo de dato que contendrá si todo sale bien.
sealed class Result<T> {
  const Result();
}

//Esto es la versión éxito de Result.
class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

//Esta es la versión error.
class Err<T> extends Result<T> {
  final List<ValidationError> errors;
  const Err(this.errors);
}

// Tu error de validación se mantiene igual
class ValidationError {
  final String message;
  ValidationError(this.message);
  @override
  String toString() => 'ValidationError: $message';
}

class Trip {
  static const int titleMax = 100;
  static const int descriptionMax = 2000;

  final String id;
  final String title;
  final String? description;
  final String? coverImage;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Trip({
    required this.id,
    required this.title,
    this.description,
    this.coverImage,
    this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  static Result<Trip> create({
    required String id,
    required String title,
    String? description,
    String? coverImage,
    DateTime? startDate,
    DateTime? endDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    final errs = <ValidationError>[];

    final t = title.trim();
    if (t.isEmpty) {
      errs.add(ValidationError('title no puede estar vacío'));
    }
    if (t.length > titleMax) {
      errs.add(ValidationError('title supera $titleMax caracteres'));
    }
    if (description != null && description.length > descriptionMax) {
      errs.add(
          ValidationError('description supera $descriptionMax caracteres'));
    }

    // Normaliza antes de comparar (evita errores por zonas horarias)
    final sUtc = startDate?.toUtc();
    final eUtc = endDate?.toUtc();
    if (sUtc != null && eUtc != null && sUtc.isAfter(eUtc)) {
      errs.add(ValidationError('startDate debe ser <= endDate'));
    }

    if (errs.isNotEmpty) {
      return Err<Trip>(errs);
    }

    return Ok<Trip>(
      Trip(
        id: id,
        title: t,
        description: description,
        coverImage: coverImage,
        startDate: sUtc,
        endDate: eUtc,
        createdAt: createdAt.toUtc(),
        updatedAt: updatedAt.toUtc(),
      ),
    );
  }
}
