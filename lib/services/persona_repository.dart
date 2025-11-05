import 'package:sqflite/sqflite.dart';
import '../database_service/db_service.dart';
import '../models/persona.dart';

class PersonaRepository {
  final _dbService = DBService();
  Set<String>? _columnsCache;

  Future<Set<String>> _getColumns(Database db) async {
    if (_columnsCache != null) return _columnsCache!;
    final rows = await db.rawQuery("PRAGMA table_info('persona')");
    _columnsCache = rows.map((r) => (r['name'] as String)).toSet();
    return _columnsCache!;
  }

  Map<String, dynamic> _filterByColumns(
      Map<String, dynamic> data, Set<String> allowed) {
    final out = <String, dynamic>{};
    data.forEach((k, v) {
      if (allowed.contains(k)) out[k] = v;
    });
    return out;
  }

  Future<void> upsert(Persona p) async {
    final db = await _dbService.db;
    final cols = await _getColumns(db);
    final data = _filterByColumns(p.toMap(), cols);
    await db.insert(
      'persona',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Persona?> findById(String id) async {
    final db = await _dbService.db;
    final res =
    await db.query('persona', where: 'id = ?', whereArgs: [id], limit: 1);
    if (res.isEmpty) return null;
    return Persona.fromMap(res.first);
  }

  Future<List<Persona>> listAll() async {
    final db = await _dbService.db;
    final res = await db.query('persona', orderBy: 'nombre COLLATE NOCASE');
    return res.map(Persona.fromMap).toList();
  }
}
