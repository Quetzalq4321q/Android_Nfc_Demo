import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/nfc_service.dart';
import 'services/persona_service.dart';

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
      ],
      child: MaterialApp(
        title: 'NFC Proyecto',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        ),
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
    Center(child: Text('Leer NFC')),
    Center(child: Text('Escribir NFC')),
    Center(child: Text('Comprobar estado')),
    Center(child: Text('Historial')),
  ];

  // 🔹 Esta es la función funcional de lectura NFC
  Future<void> _comprobarNfcYMostrar() async {
    final nfc = context.read<NfcService>();
    final personaService = context.read<PersonaService>();

    final available = await nfc.isNfcAvailableAndEnabled();
    if (!mounted) return;
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NFC no disponible o desactivado')),
      );
      return;
    }

    try {
      final id = await nfc.readNfc();
      if (!mounted) return;
      if (id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se detectó ID en la etiqueta')),
        );
        return;
      }

      final persona = await personaService.findById(id);
      if (!mounted) return;

      if (persona != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Encontrado: ${persona.nombre} • ${persona.rol}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ID no registrada: $id')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al leer NFC: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Proyecto — Demo'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Comprobar NFC',
            icon: const Icon(Icons.nfc),
            onPressed: _comprobarNfcYMostrar,
          )
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
        onPressed: _comprobarNfcYMostrar,
      ),
    );
  }
}
