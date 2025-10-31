import 'log_repository.dart';
import 'log_entry.dart';

class LogService {
  final LogRepository _repo;

  LogService({LogRepository? repo}) : _repo = repo ?? LogRepository();

  Future<List<LogEntry>> listar({int limit = 100}) => _repo.list(limit: limit);

  Future<void> limpiar() => _repo.clear();
}
