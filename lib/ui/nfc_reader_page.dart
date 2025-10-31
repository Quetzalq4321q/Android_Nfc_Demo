import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/nfc_provider.dart';

class NfcReaderPage extends StatelessWidget {
  const NfcReaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NfcProvider>(
      builder: (context, prov, _) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                prov.status,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: prov.isProcessing
                    ? null
                    : () => prov.comprobarNfcYRegistrar(),
                icon: prov.isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.nfc),
                label:
                    Text(prov.isProcessing ? 'Leyendo...' : 'Leer etiqueta NFC'),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _ReaderResult(prov: prov),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReaderResult extends StatelessWidget {
  const _ReaderResult({required this.prov});

  final NfcProvider prov;

  @override
  Widget build(BuildContext context) {
    if (prov.isProcessing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (prov.foundPersona != null) {
      final persona = prov.foundPersona!;
      return Card(
        key: const ValueKey('persona-card'),
        color: Colors.white.withOpacity(0.9),
        child: ListTile(
          leading: const Icon(Icons.verified, color: Colors.green),
          title: Text(persona.nombre),
          subtitle: Text('ID: ${persona.id}\nGrupo: ${persona.grupo}'),
        ),
      );
    }

    if (prov.failureReason != null) {
      return Card(
        key: const ValueKey('failure-card'),
        color: Colors.white.withOpacity(0.9),
        child: ListTile(
          leading: const Icon(Icons.error, color: Colors.red),
          title: Text(prov.failureReason!),
          subtitle: prov.lastId != null
              ? Text('ID leído: ${prov.lastId}')
              : null,
        ),
      );
    }

    return Center(
      key: const ValueKey('placeholder'),
      child: Text(
        'Acerca una etiqueta NFC para comenzar',
        style: Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
    );
  }
}
