import 'package:flutter/material.dart';
import '../services/acceso_service.dart';

class CheckStatusPage extends StatefulWidget {
  const CheckStatusPage({super.key});

  @override
  State<CheckStatusPage> createState() => _CheckStatusPageState();
}

class _CheckStatusPageState extends State<CheckStatusPage> {
  final _acceso = AccesoService();
  String _status = 'Listo';

  Future<void> _check() async {
    setState(() => _status = 'Acerca una credencial…');
    try {
      final ok = await _acceso.comprobarSiEsEstudianteYLoguear();
      setState(() => _status = ok ? '✅ Acceso PERMITIDO' : '⛔ Acceso DENEGADO');
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comprobar acceso')),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_status),
            const Spacer(),
            ElevatedButton(
              onPressed: _check,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Comprobar ahora'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
