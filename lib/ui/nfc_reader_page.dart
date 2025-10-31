import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/nfc_service.dart';
import '../services/persona_service.dart';

class NfcReaderPage extends StatefulWidget {
  const NfcReaderPage({super.key});
  @override
  State<NfcReaderPage> createState() => _NfcReaderPageState();
}

class _NfcReaderPageState extends State<NfcReaderPage> {
  String? _id;
  String? _info;
  bool _loading = false;

  Future<void> _leer() async {
    setState(() { _loading = true; _info = null; _id = null; });
    final nfc = context.read<NfcService>();
    try {
      final available = await nfc.isNfcAvailableAndEnabled();
      if (!mounted) return;
      if (!available) {
        setState(() { _info = 'NFC no disponible o desactivado'; _loading = false; });
        return;
      }

      final id = await nfc.readNfc();
      if (!mounted) return;
      if (id == null) {
        setState(() { _info = 'No se detectó ID'; _loading = false; });
        return;
      }

      setState(() { _id = id; });
      final persona = await context.read<PersonaService>().findById(id);
      if (!mounted) return;
      setState(() {
        if (persona != null) {
          _info = 'Encontrado: ${persona.nombre} (${persona.rol})';
        } else {
          _info = 'ID no registrada. Puedes ir a Escribir para registrar.';
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _info = 'Error: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(children: [
        ElevatedButton.icon(icon: const Icon(Icons.nfc), label: const Text('Leer etiqueta NFC'), onPressed: _loading ? null : _leer),
        const SizedBox(height: 20),
        if (_loading) const CircularProgressIndicator(),
        if (_id != null) SelectableText('ID: $_id'),
        if (_info != null) Padding(padding: const EdgeInsets.only(top: 12.0), child: Text(_info!)),
      ]),
    );
  }
}
