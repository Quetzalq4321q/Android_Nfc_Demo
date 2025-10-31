import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/nfc_provider.dart';
import 'services/log_service.dart';
import 'services/nfc_service.dart';
import 'services/persona_service.dart';
import 'ui/check_status_page.dart';
import 'ui/logs_page.dart';
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
        ChangeNotifierProvider(
          create: (context) => NfcProvider(
            nfcService: context.read<NfcService>(),
            personaService: context.read<PersonaService>(),
            logService: context.read<LogService>(),
          ),
        ),
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
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      NfcReaderPage(),
      WriteNfcPage(),
      CheckStatusPage(),
      LogsPage(),
    ];
  }

  /// Solicita al proveedor que ejecute el flujo de lectura y registre el log
  Future<void> _comprobarNfcYRegistrar() async {
    await context.read<NfcProvider>().comprobarNfcYRegistrar();
  }

  @override
  Widget build(BuildContext context) {
    final nfcProvider = context.watch<NfcProvider>();
    final isReaderTab = _currentIndex == 0;
    final scaffoldColor = isReaderTab ? nfcProvider.backgroundColor : null;

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        title: const Text('NFC Proyecto'),
        centerTitle: true,
        actions: [
          if (isReaderTab)
            IconButton(
              tooltip: 'Comprobar NFC',
              icon: const Icon(Icons.nfc),
              onPressed:
                  nfcProvider.isProcessing ? null : _comprobarNfcYRegistrar,
            ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
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
      floatingActionButton: isReaderTab
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Probar lectura NFC'),
              onPressed:
                  nfcProvider.isProcessing ? null : _comprobarNfcYRegistrar,
            )
          : null,
    );
  }
}
