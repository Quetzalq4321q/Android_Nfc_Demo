import '../utils/id_utils.dart';

/// Representa una persona o estudiante registrada en la base de datos.
/// Guarda el identificador NFC normalizado, nombre y grupo.
class Persona {
  final String id;
  final String nombre;
  final String grupo;

  Persona({
    required String id,
    required this.nombre,
    required this.grupo,
  }) : id = normalizeId(id);

  factory Persona.fromMap(Map<String, dynamic> m) {
    final rawId = m['id']?.toString() ?? '';
    return Persona(
      id: normalizeId(rawId),
      nombre: m['nombre']?.toString() ?? '',
      grupo: m['grupo']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'grupo': grupo,
  };
}
