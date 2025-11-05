import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'database_service/db_service.dart';
import 'providers/nfc_provider.dart';

// UI pages (asegúrate de tener estos archivos con las clases correspondientes)
import 'ui/home_page.dart';
import 'ui/nfc_reader_page.dart';
import 'ui/write_nfc_page.dart';
import 'ui/logs_page.dart';
import 'ui/check_status_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Abre/crea la BD antes de levantar la UI para asegurar onCreate/onUpgrade
  await DBService().db;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NfcProvider>(
          create: (_) => NfcProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NFC Proyecto',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0066CC)),
          useMaterial3: true,
        ),
        home: const HomePage(),
        routes: {
          '/home': (context) => const HomePage(),
          '/read': (context) => const NfcReaderPage(),
          '/write': (context) => const WriteNfcPage(),
          '/logs': (context) => const LogsPage(),
          '/check': (context) => const CheckStatusPage(),
        },
      ),
    );
  }
}
