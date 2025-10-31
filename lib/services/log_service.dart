import 'package:sqflite/sqflite.dart';
import '../database_service/db_service.dart';

/// Servicio para manejar los registros de lecturas NFC en la base de datos.
/// Guarda el id leído, la fecha y el resultado del intento de verificación.
class LogService {
  final DBService _dbService = DBService();

  /// Inserta un nuevo registro de log en la base de datos.
  Future<void> insertLog(String tagId, String resultado) async {
    final db = await _dbService.db;
    final fecha = DateTime.now().toIso8601String();

    await db.insert(
      'logs',
      {
        'tag_id': tagId,
        'fecha': fecha,
        'resultado': resultado,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Devuelve todos los registros guardados ordenados por fecha descendente.
  Future<List<Map<String, dynamic>>> getLogs() async {
    final db = await _dbService.db;
    return await db.query(
      'logs',
      orderBy: 'fecha DESC',
    );
  }

  /// Elimina todos los registros de la tabla logs.
  Future<void> clearLogs() async {
    final db = await _dbService.db;
    await db.delete('logs');
  }
}
