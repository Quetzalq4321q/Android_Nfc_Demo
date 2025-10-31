import 'package:uuid/uuid.dart';
import '../models/persona.dart';

class PersonaService {
  final _uuid = const Uuid();
  final List<Persona> _personas = [];

  Future<Persona> createPersonaDemo() async {
    final persona = Persona(
      id: _uuid.v4(),
      nombre: 'Alumno ${_personas.length + 1}',
      dni: '00000000',
      rol: 'Alumno',
      estado: 'activo',
    );
    _personas.add(persona);
    return persona;
  }

  Future<Persona?> findById(String id) async {
    try {
      return _personas.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Persona>> allPersonas() async => _personas;
}
