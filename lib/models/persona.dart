// lib/models/persona.dart

class Persona {
  final String id;
  String nombre;
  String dni;
  String rol;
  String estado;
  DateTime creadoEn;

  Persona({
    required this.id,
    required this.nombre,
    required this.dni,
    required this.rol,
    required this.estado,
    DateTime? creadoEn,
  }) : creadoEn = creadoEn ?? DateTime.now();

  /// Serialización JSON simple
  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'dni': dni,
    'rol': rol,
    'estado': estado,
    'creadoEn': creadoEn.toIso8601String(),
  };

  factory Persona.fromJson(Map<String, dynamic> m) {
    DateTime creado;
    try {
      creado = DateTime.parse(m['creadoEn']?.toString() ?? DateTime.now().toIso8601String());
    } catch (_) {
      creado = DateTime.now();
    }
    return Persona(
      id: m['id']?.toString() ?? '',
      nombre: m['nombre']?.toString() ?? '',
      dni: m['dni']?.toString() ?? '',
      rol: m['rol']?.toString() ?? '',
      estado: m['estado']?.toString() ?? '',
      creadoEn: creado,
    );
  }

  @override
  String toString() {
    return 'Persona(id: $id, nombre: $nombre, dni: $dni, rol: $rol, estado: $estado, creadoEn: $creadoEn)';
  }
}
