import 'package:flutter/material.dart';
import '../services/log_repository.dart';
import '../services/log_entry.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  final LogRepository _logRepo = LogRepository();
  List<LogEntry> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final logs = await _logRepo.list(limit: 100);
    setState(() {
      _logs = logs;
      _loading = false;
    });
  }

  Future<void> _clearLogs() async {
    await _logRepo.clear();
    await _loadLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registros de Acceso'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Borrar todos los logs',
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Confirmar'),
                  content: const Text('¿Seguro que deseas eliminar todos los logs?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );
              if (ok == true) _clearLogs();
            },
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
          ? const Center(child: Text('No hay registros guardados.'))
          : RefreshIndicator(
        onRefresh: _loadLogs,
        child: ListView.builder(
          itemCount: _logs.length,
          itemBuilder: (context, index) {
            final log = _logs[index];
            return ListTile(
              leading: Icon(
                log.resultado.contains('permitido')
                    ? Icons.check_circle
                    : Icons.cancel,
                color: log.resultado.contains('permitido')
                    ? Colors.green
                    : Colors.red,
              ),
              title: Text('Tag: ${log.tagId}'),
              subtitle: Text(
                '${log.resultado} • ${log.fecha}',
                style: const TextStyle(fontSize: 13),
              ),
            );
          },
        ),
      ),
    );
  }
}
