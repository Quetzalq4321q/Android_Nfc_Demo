import 'package:flutter/material.dart';

import '../models/persona.dart';
import '../services/persona_service.dart';

class CheckStatusPage extends StatefulWidget {
  const CheckStatusPage({super.key});

  @override
  State<CheckStatusPage> createState() => _CheckStatusPageState();
}

class _CheckStatusPageState extends State<CheckStatusPage> {
  final _idCtrl = TextEditingController();
  final PersonaService _personaService = PersonaService();
  Persona? _found;
  String _status = '';
  bool _isImporting = false;
  bool _isExporting = false;

  @override
  void dispose() {
    _idCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _idCtrl,
            decoration: const InputDecoration(labelText: 'ID a buscar'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              final id = _idCtrl.text.trim();
              if (id.isEmpty) return;
              final p = await _personaService.getPersonaById(id);
              setState(() {
                _found = p;
                _status = p == null ? 'No registrado' : 'Encontrado';
              });
            },
            child: const Text('Buscar'),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                icon: _isImporting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_file),
                label: const Text('Importar CSV'),
                onPressed: _isImporting ? null : _handleImportCsv,
              ),
              OutlinedButton.icon(
                icon: _isExporting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download),
                label: const Text('Exportar CSV'),
                onPressed: _isExporting ? null : _handleExportCsv,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_status.isNotEmpty)
            Text(
              _status,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          if (_found != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Card(
                child: ListTile(
                  title: Text(_found!.nombre),
                  subtitle:
                      Text('ID: ${_found!.id}\nGrupo: ${_found!.grupo}'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleImportCsv() async {
    final csv = await _promptCsvContent();
    if (csv == null || csv.trim().isEmpty) return;

    setState(() => _isImporting = true);
    try {
      final count = await _personaService.importPersonasFromCsv(csv);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Importación completada: $count registros.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al importar CSV: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  Future<void> _handleExportCsv() async {
    setState(() => _isExporting = true);
    try {
      final csv = await _personaService.exportPersonasToCsv();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('CSV exportado'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: SelectableText(csv),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar CSV: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<String?> _promptCsvContent() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importar CSV'),
        content: TextField(
          controller: controller,
          maxLines: 10,
          decoration: const InputDecoration(
            hintText: 'Pega aquí el contenido CSV (id,nombre,grupo)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Importar'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }
}
