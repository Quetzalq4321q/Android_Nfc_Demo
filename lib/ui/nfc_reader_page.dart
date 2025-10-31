// ui/nfc_reader_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/nfc_provider.dart';

class NfcReaderPage extends StatelessWidget {
  const NfcReaderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<NfcProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Lector NFC')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(prov.status),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.read<NfcProvider>().startRead(),
              icon: const Icon(Icons.nfc),
              label: const Text('Leer NFC'),
            ),
            const SizedBox(height: 12),
            if (prov.foundPersona != null)
              Card(
                child: ListTile(
                  title: Text(prov.foundPersona!.nombre),
                  subtitle: Text('ID: ${prov.foundPersona!.id}\nGrupo: ${prov.foundPersona!.grupo}'),
                ),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/write'),
              child: const Text('Escribir NFC / Registrar persona'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/check'),
              child: const Text('Comprobar status (manual)'),
            ),
          ],
        ),
      ),
    );
  }
}
