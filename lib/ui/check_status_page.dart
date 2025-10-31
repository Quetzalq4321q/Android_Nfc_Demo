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
}
