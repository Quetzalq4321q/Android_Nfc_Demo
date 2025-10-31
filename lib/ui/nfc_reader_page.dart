import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nfc_provider.dart';

class NfcReaderPage extends StatelessWidget {
  const NfcReaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NfcProvider>();

    return Scaffold(
      backgroundColor: Colors.black, // para contraste del shader
      appBar: AppBar(
        title: const Text('Leer NFC'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const _AnimatedColorfulBackground(),
          SafeArea(
            minimum: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        'NFC Proyecto',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // STATUS CARD
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

                // INFO CARD
                if (provider.lastId != null || provider.foundPersona != null)
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (provider.lastId != null)
                            Text(
                              'Último ID: ${provider.lastId}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          if (provider.foundPersona != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.person, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    provider.foundPersona!.nombre,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.group, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  provider.foundPersona!.grupo ?? '-',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                const Spacer(),

                // BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.nfc),
                        onPressed: () => context.read<NfcProvider>().startRead(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        label: const Text('Leer etiqueta'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => context.read<NfcProvider>().clear(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: const BorderSide(width: 1.4),
                        ),
                        label: const Text('Limpiar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Fondo animado colorido (ligero y sin libs)
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
          -1 + 2 * _c.value,
          1 - 2 * _c.value,
        );
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: alignment,
              radius: 1.2,
              colors: const [
                Color(0xFF4F46E5), // indigo
                Color(0xFF06B6D4), // cyan
                Color(0xFFF59E0B), // amber
                Color(0xFF10B981), // emerald
              ],
              stops: const [0.10, 0.35, 0.70, 1.0],
            ),
          ),
        );
      },
    );
  }
}
