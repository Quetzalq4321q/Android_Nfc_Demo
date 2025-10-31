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
  final TextEditingController _filterController = TextEditingController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _logsFuture = Future.value(const []);
    _filterController.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _logsFuture = context.read<LogService>().getLogs();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  Future<void> _refreshLogs() async {
    final future = context.read<LogService>().getLogs();
    setState(() {
      _logsFuture = future;
    });
    await future;
  }

  Future<void> _clearLogs() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar historial'),
        content: const Text('¿Deseas eliminar todos los registros de logs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await context.read<LogService>().clearLogs();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Historial eliminado correctamente.')),
      );
      await _refreshLogs();
    }
  }

  void _clearFilter() {
    _filterController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _filterController,
                  decoration: InputDecoration(
                    labelText: 'Filtrar por tag o resultado',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _filterController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: _clearFilter,
                            icon: const Icon(Icons.close),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Actualizar',
                onPressed: _refreshLogs,
                icon: const Icon(Icons.refresh),
              ),
              IconButton(
                tooltip: 'Limpiar historial',
                onPressed: _clearLogs,
                icon: const Icon(Icons.delete_sweep),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _logsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error al cargar los logs: ${snapshot.error}'),
                );
              }

              final logs = snapshot.data ?? [];
              final filter = _filterController.text.toLowerCase();
              final filteredLogs = filter.isEmpty
                  ? logs
                  : logs.where((log) {
                      final tag = (log['tag_id'] ?? '').toString().toLowerCase();
                      final resultado =
                          (log['resultado'] ?? '').toString().toLowerCase();
                      return tag.contains(filter) || resultado.contains(filter);
                    }).toList();

              if (filteredLogs.isEmpty) {
                return const Center(
                  child: Text('No hay registros para mostrar.'),
                );
              }

              return RefreshIndicator(
                onRefresh: _refreshLogs,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredLogs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final log = filteredLogs[index];
                    final tag = (log['tag_id'] ?? '').toString();
                    final resultado = (log['resultado'] ?? '').toString();
                    final fechaIso = (log['fecha'] ?? '').toString();
                    DateTime? fecha;
                    try {
                      fecha = DateTime.parse(fechaIso).toLocal();
                    } catch (_) {}

                    final fechaFormateada = fecha != null
                        ? '${fecha.day.toString().padLeft(2, '0')}/'
                            '${fecha.month.toString().padLeft(2, '0')}/'
                            '${fecha.year} '
                            '${fecha.hour.toString().padLeft(2, '0')}:'
                            '${fecha.minute.toString().padLeft(2, '0')}'
                        : fechaIso;

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.nfc),
                        title: Text('Tag: $tag'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fecha: $fechaFormateada'),
                            Text('Resultado: $resultado'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
