import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/nfc_provider.dart';

class WriteNfcPage extends StatefulWidget {
  const WriteNfcPage({super.key});

  @override
  State<WriteNfcPage> createState() => _WriteNfcPageState();
}

class _WriteNfcPageState extends State<WriteNfcPage> {
  final _idCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _groupCtrl = TextEditingController();

  @override
  void dispose() {
    _idCtrl.dispose();
    _nameCtrl.dispose();
    _groupCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<NfcProvider>(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Estado: ${prov.status}'),
          const SizedBox(height: 12),
          TextField(
            controller: _idCtrl,
            decoration: const InputDecoration(
              labelText: 'ID a escribir (hex o string)',
            ),
          ),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          TextField(
            controller: _groupCtrl,
            decoration: const InputDecoration(labelText: 'Grupo'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final id = _idCtrl.text.trim();
              final nombre = _nameCtrl.text.trim();
              final grupo = _groupCtrl.text.trim();
              if (id.isEmpty || nombre.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ID y Nombre son obligatorios')),
                );
                return;
              }
              prov.writeAndSave(
                id,
                nombre,
                grupo,
                onError: (err) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $err')),
                  );
                },
                onSuccess: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Escrito y guardado en DB')),
                  );
                },
              );
            },
            child: const Text('Escribir etiqueta y guardar'),
          ),
        ],
      ),
    );
  }
}
