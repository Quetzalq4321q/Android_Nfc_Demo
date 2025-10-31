// lib/database_service/db_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  Future<File> _localFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/personas.json';
    final file = File(path);
    if (!await file.exists()) {
      // crear archivo con un mapa vacío
      await file.writeAsString(jsonEncode({}), flush: true);
    }
    return file;
  }

  /// Guarda/actualiza una persona serializada (mapa). Key = id
  Future<void> savePersonaMap(String id, Map<String, dynamic> personaMap) async {
    final file = await _localFile();
    final content = await file.readAsString();
    Map<String, dynamic> data;
    try {
      data = jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      data = {};
    }
    data[id] = personaMap;
    await file.writeAsString(jsonEncode(data), flush: true);
  }

  /// Lee una persona por id, retorna el mapa o null
  Future<Map<String, dynamic>?> readPersonaMap(String id) async {
    final file = await _localFile();
    final content = await file.readAsString();
    Map<String, dynamic> data;
    try {
      data = jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
    final entry = data[id];
    if (entry == null) return null;
    return Map<String, dynamic>.from(entry);
  }

  /// Devuelve todas las personas como Map<id, map>
  Future<Map<String, dynamic>> readAllAsMap() async {
    final file = await _localFile();
    final content = await file.readAsString();
    try {
      final data = jsonDecode(content) as Map<String, dynamic>;
      return data;
    } catch (_) {
      return {};
    }
  }

  /// Borra una persona por id. Retorna true si existía y fue borrada.
  Future<bool> deleteById(String id) async {
    final file = await _localFile();
    final content = await file.readAsString();
    Map<String, dynamic> data;
    try {
      data = jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      return false;
    }
    if (!data.containsKey(id)) return false;
    data.remove(id);
    await file.writeAsString(jsonEncode(data), flush: true);
    return true;
  }

  /// Exporta el JSON a un archivo nuevo y devuelve la ruta (útil para compartir)
  Future<String> exportJson({String? fileName}) async {
    final dir = await getApplicationDocumentsDirectory();
    final exportName = fileName ?? 'personas_export_${DateTime.now().millisecondsSinceEpoch}.json';
    final exportPath = '${dir.path}/$exportName';
    final data = await readAllAsMap();
    final f = File(exportPath);
    await f.writeAsString(jsonEncode(data), flush: true);
    return exportPath;
  }
}
