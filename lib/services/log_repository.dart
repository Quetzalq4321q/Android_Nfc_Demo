import '../database_service/db_service.dart';
import 'log_entry.dart';
class LogRepository {
  final _dbService = DBService();

  Future<int> add(LogEntry log) async {
    final db = await _dbService.db;
    return await db.insert('logs', log.toMap());
  }

  Future<List<LogEntry>> list({int limit = 100, bool newestFirst = true}) async {
    final db = await _dbService.db;
    final order = newestFirst ? 'id DESC' : 'id ASC';
    final res = await db.query('logs', orderBy: order, limit: limit);
    return res.map(LogEntry.fromMap).toList();
  }

  Future<void> clear() async {
    final db = await _dbService.db;
    await db.delete('logs');
  }
}
