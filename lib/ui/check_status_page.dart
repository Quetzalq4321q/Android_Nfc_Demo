// ui/check_status_page.dart
import 'package:flutter/material.dart';
import '../services/persona_service.dart';
import '../models/persona.dart';

class CheckStatusPage extends StatefulWidget {
  const CheckStatusPage({Key? key}) : super(key: key);

  @override
  State<CheckStatusPage> createState() => _CheckStatusPageState();
}

class _CheckStatusPageState extends State<CheckStatusPage> {
  final _idCtrl = TextEditingController();
  final PersonaService _personaService = PersonaService();
  Persona? _found;
  String _status = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comprobar status')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _idCtrl, decoration: const InputDecoration(labelText: 'ID a buscar')),
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
            Text(_status),
            if (_found != null)
              Card(
                child: ListTile(
                  title: Text(_found!.nombre),
                  subtitle: Text('ID: ${_found!.id}\nGrupo: ${_found!.grupo}'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
