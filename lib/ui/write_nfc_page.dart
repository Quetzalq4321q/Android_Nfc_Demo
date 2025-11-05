import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nfc_provider.dart';

class WriteNfcPage extends StatefulWidget {
  const WriteNfcPage({super.key});

  @override
  State<WriteNfcPage> createState() => _WriteNfcPageState();
}

class _WriteNfcPageState extends State<WriteNfcPage> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _grupoCtrl = TextEditingController(text: 'alumno');

  @override
  void dispose() {
    _idCtrl.dispose();
    _nombreCtrl.dispose();
    _grupoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NfcProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Escribir NFC'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const _AnimatedColorfulBackground(),
          SafeArea(
            minimum: const EdgeInsets.all(16),
            child: Column(
              children: [
                // LOGO
                Center(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/icon.png',
                          height: 82,
                          width: 82,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Programación NFC',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // STATUS
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      provider.status,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // FORM
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _idCtrl,
                            decoration: const InputDecoration(
                              labelText: 'ID a grabar (NDEF texto)',
                              hintText: 'Ej. 04A224C3D67280',
                              prefixIcon: Icon(Icons.tag),
                            ),
                            validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Ingresa un ID' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _nombreCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Nombre',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _grupoCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Grupo / Tipo (alumno | no_alumno)',
                              prefixIcon: Icon(Icons.group),
                            ),
                            validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Ingresa un grupo' : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // BUTTONS
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    onPressed: () async {
                      final isValid = _formKey.currentState?.validate() ?? false; // <— sin !
                      if (!isValid) return;

                      final id = _idCtrl.text.trim();
                      final nombre = _nombreCtrl.text.trim();
                      final grupo = _grupoCtrl.text.trim();

                      await context.read<NfcProvider>().writeAndSave(
                        id,
                        nombre,
                        grupo,
                        onError: (msg) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $msg')),
                          );
                        },
                        onSuccess: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Etiqueta escrita y guardada')),
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    label: const Text('Escribir y guardar'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.clear_all),
                    onPressed: () {
                      _idCtrl.clear();
                      _nombreCtrl.clear();
                      _grupoCtrl.text = 'alumno';
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: const BorderSide(width: 1.4),
                    ),
                    label: const Text('Limpiar campos'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Copiamos el mismo fondo animado para esta página.
class _AnimatedColorfulBackground extends StatefulWidget {
  const _AnimatedColorfulBackground();

  @override
  State<_AnimatedColorfulBackground> createState() =>
      _AnimatedColorfulBackgroundState();
}

class _AnimatedColorfulBackgroundState
    extends State<_AnimatedColorfulBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final alignment = Alignment(
          1 - 2 * _c.value,
          -1 + 2 * _c.value,
        );
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: alignment,
              radius: 1.2,
              colors: const [
                Color(0xFFEC4899), // pink
                Color(0xFF8B5CF6), // violet
                Color(0xFF3B82F6), // blue
                Color(0xFF22C55E), // green
              ],
              stops: const [0.10, 0.40, 0.75, 1.0],
            ),
          ),
        );
      },
    );
  }
}
