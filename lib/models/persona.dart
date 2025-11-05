class Persona {
  final String id;               // Tag ID o ID lógico (lo que lees/escribes)
  final String nombre;
  final String? grupo;           // compat v2
  final String? dni;             // si migras a v3
  final String? fechaNacimiento; // si migras a v3 ("YYYY-MM-DD")
  final String? tipo;            // si migras a v3 ("alumno"/"no_alumno")

  Persona({
    required this.id,
    required this.nombre,
    this.grupo,
    this.dni,
    this.fechaNacimiento,
    this.tipo,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'grupo': grupo,
    'dni': dni,
    'fecha_nacimiento': fechaNacimiento,
    'tipo': tipo,
  }..removeWhere((k, v) => v == null);

  factory Persona.fromMap(Map<String, dynamic> map) => Persona(
    id: map['id'] as String,
    nombre: (map['nombre'] ?? '') as String,
    grupo: map['grupo'] as String?,
    dni: map['dni'] as String?,
    fechaNacimiento: map['fecha_nacimiento'] as String?,
    tipo: map['tipo'] as String?,
  );

  /// True si (tipo == alumno) o (grupo == alumno) para compatibilidad con v2.
  bool get esAlumno {
    final t = (tipo ?? '').toLowerCase();
    final g = (grupo ?? '').toLowerCase();
    return t == 'alumno' || g == 'alumno';
  }
}
