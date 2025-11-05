import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget btn(String text, String route) => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(text),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('NFC Proyecto')),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            btn('Leer NFC', '/read'),
            const SizedBox(height: 12),
            btn('Escribir NFC', '/write'),
            const SizedBox(height: 12),
            btn('Ver Logs', '/logs'),
            const SizedBox(height: 12),
            btn('Comprobar acceso (leer + log)', '/check'),
          ],
        ),
      ),
    );
  }
}
