// lib/services/acceso_service.dart
import '../models/persona.dart';
import 'log_entry.dart';
import 'log_repository.dart';
import 'persona_repository.dart';
import 'nfc_reader_service.dart';
import 'nfc_writer_service.dart';

/// Servicio que orquesta el flujo de acceso:
/// 1) Lee NFC (NDEF texto o UID) y verifica si es estudiante.
/// 2) Registra logs en SQLite.
/// 3) Escribe un usuario en el tag y lo guarda/actualiza en la BD.
class AccesoService {
  final NfcReaderService _reader;
  final NfcWriterService _writer;
  final PersonaRepository _personas;
  final LogRepository _logs;

  AccesoService({
    NfcReaderService? reader,
    NfcWriterService? writer,
    PersonaRepository? personas,
    LogRepository? logs,
  })  : _reader = reader ?? NfcReaderService(),
        _writer = writer ?? NfcWriterService(),
        _personas = personas ?? PersonaRepository(),
        _logs = logs ?? LogRepository();

  String _nowIso() => DateTime.now().toIso8601String();

  /// (1) Lee el tag, verifica si la persona es alumno y genera un log.
  /// Devuelve true si acceso permitido (alumno), false si denegado.
  Future<bool> comprobarSiEsEstudianteYLoguear() async {
    final tagValue = await _reader.readId();

    if (tagValue == null || tagValue.isEmpty) {
      await _logs.add(LogEntry(
        tagId: 'SIN_TAG',
        fecha: _nowIso(),
        resultado: 'denegado: sin tag',
      ));
      return false;
    }

    final p = await _personas.findById(tagValue);
    final allowed = (p != null) && p.esAlumno;

    await _logs.add(LogEntry(
      tagId: tagValue,
      fecha: _nowIso(),
      resultado: allowed ? 'permitido' : 'denegado',
    ));

    return allowed;
  }

  /// (2) Devuelve los últimos logs (para mostrarlos en la UI).
  Future<List<LogEntry>> obtenerLogs({int limit = 100}) => _logs.list(limit: limit);

  /// (2) Devuelve las personas (para listarlas en UI).
  Future<List<Persona>> obtenerEstudiantes() => _personas.listAll();

  /// (3) Escribe el ID de la persona en el tag (NDEF texto) y guarda/actualiza en BD.
  Future<void> escribirUsuarioYTag(Persona p) async {
    await _writer.writeId(p.id);   // escribe el NDEF con 'id' como texto
    await _personas.upsert(p);     // guarda o actualiza en SQLite
  }
}
