// lib/services/persona_service.dart
import 'dart:convert';
import '../models/persona.dart';
import 'persona_repository.dart';

class PersonaService {
  final PersonaRepository _repo;

  PersonaService({PersonaRepository? repo}) : _repo = repo ?? PersonaRepository();

  /// Mantiene compatibilidad con NfcProvider.startRead()
  Future<Persona?> getPersonaById(String id) {
    return _repo.findById(id);
  }

  /// Mantiene compatibilidad con NfcProvider.writeAndSave()
  Future<void> insertOrReplacePersona(Persona p) {
    return _repo.upsert(p);
  }

  /// Extra helpers (por si los necesitas en tus páginas)
  Future<List<Persona>> getAllPersonas() => _repo.listAll();

  /// Importa una lista JSON como la que compartiste
  Future<void> importFromJson(String jsonText) async {
    final List<dynamic> data = json.decode(jsonText) as List<dynamic>;
    for (final raw in data) {
      final m = raw as Map<String, dynamic>;
      final p = Persona(
        id: m['id'] as String,
        nombre: (m['nombre'] ?? '') as String,
        grupo: m['grupo'] as String?, // compat v2
        dni: m['dni'] as String?,
        fechaNacimiento: m['fecha_nacimiento'] as String?,
        tipo: m['tipo'] as String?,
      );
      await _repo.upsert(p);
    }
  }
}
