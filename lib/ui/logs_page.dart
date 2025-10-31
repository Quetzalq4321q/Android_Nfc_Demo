import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/log_service.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  late Future<List<Map<String, dynamic>>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _logsFuture = _loadLogs();
  }

  Future<List<Map<String, dynamic>>> _loadLogs() {
    final logService = context.read<LogService>();
    return logService.getLogs();
  }

  Future<void> _refresh() async {
    setState(() {
      _logsFuture = _loadLogs();
    });
    await _logsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _logsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ListView(
              physics: AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          }

          if (snapshot.hasError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No se pudieron cargar los registros'),
                ),
              ],
            );
          }

          final logs = snapshot.data ?? [];
          if (logs.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Sin registros aún'),
                ),
              ],
            );
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final log = logs[index];
              final fecha = DateTime.tryParse(log['fecha'] as String? ?? '');
              final fechaLegible = fecha != null
                  ? '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}'
                  : 'Fecha desconocida';

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(log['resultado'] as String? ?? ''),
                  subtitle: Text('ID: ${log['tag_id']}\n$fechaLegible'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
