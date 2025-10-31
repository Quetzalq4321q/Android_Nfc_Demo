import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/nfc_provider.dart';
import 'services/log_service.dart';
import 'services/nfc_service.dart';
import 'services/persona_service.dart';
import 'ui/check_status_page.dart';
import 'ui/nfc_reader_page.dart';
import 'ui/write_nfc_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => PersonaService()),
        Provider(create: (_) => NfcService()),
        Provider(create: (_) => LogService()),
        ChangeNotifierProvider(create: (_) => NfcProvider()),
      ],
      child: MaterialApp(
        title: 'NFC Proyecto',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        ),
        routes: {
          '/read': (context) => const NfcReaderPage(),
          '/write': (context) => const WriteNfcPage(),
          '/check': (context) => const CheckStatusPage(),
        },
        home: const HomeScreenWrapper(),
      ),
    );
  }
}

class HomeScreenWrapper extends StatefulWidget {
  const HomeScreenWrapper({super.key});

  @override
  State<HomeScreenWrapper> createState() => _HomeScreenWrapperState();
}

class _HomeScreenWrapperState extends State<HomeScreenWrapper> {
  int _currentIndex = 0;

  static const List<Widget> _demoPages = <Widget>[
    NfcReaderPage(),
    WriteNfcPage(),
    CheckStatusPage(),
    Center(child: Text('Historial')),
  ];

  /// Función que realiza el proceso de lectura, validación y registro de logs
  Future<void> _comprobarNfcYRegistrar() async {
    final nfcService = context.read<NfcService>();
    final personaService = context.read<PersonaService>();
    final logService = context.read<LogService>();

    final disponible = await nfcService.isNfcAvailableAndEnabled();
    if (!mounted) return;
    if (!disponible) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NFC no disponible o desactivado')),
      );
      await logService.insertLog('SIN_DISPONIBILIDAD', 'NFC desactivado');
      return;
    }

    try {
      final id = await nfcService.readNfc();
      if (!mounted) return;

      if (id == null || id.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se detectó ID en la etiqueta')),
        );
        await logService.insertLog('SIN_ID', 'Etiqueta sin ID');
        return;
      }

      final persona = await personaService.getPersonaById(id);

      if (persona != null) {
        final mensaje = 'Encontrado: ${persona.nombre} • ${persona.grupo}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensaje)),
        );
        await logService.insertLog(id, 'Verificación correcta');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ID no registrada: $id')),
        );
        await logService.insertLog(id, 'ID no registrada');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al leer NFC: $e')),
      );
      await logService.insertLog('ERROR', 'Error al leer NFC: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Proyecto'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Comprobar NFC',
            icon: const Icon(Icons.nfc),
            onPressed: _comprobarNfcYRegistrar,
          ),
        ],
      ),
      body: _demoPages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.nfc), label: 'Leer'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Escribir'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Comprobar'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.play_arrow),
        label: const Text('Probar lectura NFC'),
        onPressed: _comprobarNfcYRegistrar,
      ),
    );
  }
}
