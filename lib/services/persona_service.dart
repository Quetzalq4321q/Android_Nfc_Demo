// services/persona_service.dart
import 'package:sqflite/sqflite.dart';
import '../database_service/db_service.dart';
import '../models/persona.dart';

class PersonaService {
  final DBService _dbService = DBService();

  Future<Persona?> getPersonaById(String id) async {
    final db = await _dbService.db;
    final maps = await db.query(
      'persona',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Persona.fromMap(maps.first);
  }

  Future<bool> hasPersonaById(String id) async {
    final p = await getPersonaById(id);
    return p != null;
  }

  Future<void> insertOrReplacePersona(Persona persona) async {
    final db = await _dbService.db;
    await db.insert(
      'persona',
      persona.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Persona>> allPersonas() async {
    final db = await _dbService.db;
    final result = await db.query('persona');
    return result.map((m) => Persona.fromMap(m)).toList();
  }

  Future<void> deletePersona(String id) async {
    final db = await _dbService.db;
    await db.delete('persona', where: 'id = ?', whereArgs: [id]);
  }
}
