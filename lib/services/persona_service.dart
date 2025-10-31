// services/persona_service.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:sqflite/sqflite.dart';
import '../database_service/db_service.dart';
import '../models/persona.dart';
import '../utils/csv_helper.dart';

class PersonaService {
  final DBService _dbService = DBService();
  String? lastSeedError;

  /// Carga los registros iniciales desde [assetPath] cuando la tabla `persona`
  /// está vacía. Devuelve la cantidad de filas insertadas o `-1` si ocurrió un
  /// error.
  Future<int> seedDatabaseIfEmptyFromAsset({
    String assetPath = 'assets/data/estudiantes.json',
  }) async {
    lastSeedError = null;
    try {
      final db = await _dbService.db;
      final countResult = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM persona'),
      );
      if ((countResult ?? 0) > 0) {
        return 0;
      }

      final jsonString = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(jsonString);
      if (decoded is! List) {
        throw const FormatException(
          'El archivo de semilla debe ser una lista de objetos JSON.',
        );
      }

      final personas = decoded
          .whereType<Map<String, dynamic>>()
          .map((map) {
            final rawGroup = map['grupo'];
            final normalizedGroup = rawGroup != null &&
                    rawGroup.toString().trim().isNotEmpty
                ? rawGroup.toString()
                : map['tipo']?.toString() ?? map['dni']?.toString() ?? '';
            return Persona(
              id: map['id']?.toString() ?? '',
              nombre: map['nombre']?.toString() ?? '',
              grupo: normalizedGroup,
            );
          })
          .where((persona) => persona.id.isNotEmpty)
          .toList();

      if (personas.isEmpty) {
        debugPrint(
          'No se insertaron datos de semilla porque el archivo no contenía IDs válidos.',
        );
        return 0;
      }

      await db.transaction((txn) async {
        final batch = txn.batch();
        for (final persona in personas) {
          batch.insert(
            'persona',
            persona.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true);
      });

      debugPrint(
        'Se cargaron ${personas.length} registros iniciales desde $assetPath.',
      );
      return personas.length;
    } catch (e, stackTrace) {
      lastSeedError = 'No se pudo cargar la semilla inicial: $e';
      debugPrint(lastSeedError);
      debugPrint(stackTrace.toString());
      return -1;
    }
  }

  Future<Persona?> getPersonaById(String id) async {
    final db = await _dbService.db;
    final maps = await db.query(
      'persona',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Persona.fromMap(maps.first);
  }

  Future<bool> hasPersonaById(String id) async {
    final p = await getPersonaById(id);
    return p != null;
  }

  Future<void> insertOrReplacePersona(Persona persona) async {
    final db = await _dbService.db;
    await db.insert(
      'persona',
      persona.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Persona>> allPersonas() async {
    final db = await _dbService.db;
    final result = await db.query('persona');
    return result.map((m) => Persona.fromMap(m)).toList();
  }

  /// Reemplaza el contenido de la tabla `persona` por los datos provenientes del
  /// [csvContent]. Devuelve la cantidad de registros insertados.
  Future<int> importPersonasFromCsv(
    String csvContent, {
    bool hasHeader = true,
  }) async {
    final personas = personasFromCsv(csvContent, hasHeader: hasHeader);
    return _replaceAllPersonas(personas);
  }

  /// Variante de [importPersonasFromCsv] que recibe los bytes de un archivo CSV.
  Future<int> importPersonasFromCsvBytes(
    Uint8List bytes, {
    bool hasHeader = true,
  }) async {
    final personas = personasFromCsvBytes(bytes, hasHeader: hasHeader);
    return _replaceAllPersonas(personas);
  }

  /// Devuelve el contenido de la tabla `persona` en formato CSV.
  Future<String> exportPersonasToCsv({bool includeHeader = true}) async {
    final personas = await allPersonas();
    return personasToCsv(personas, includeHeader: includeHeader);
  }

  /// Devuelve los bytes en UTF-8 del CSV con todos los registros de persona.
  Future<Uint8List> exportPersonasToCsvBytes({bool includeHeader = true}) async {
    final personas = await allPersonas();
    return personasToCsvBytes(personas, includeHeader: includeHeader);
  }

  Future<void> deletePersona(String id) async {
    final db = await _dbService.db;
    await db.delete('persona', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> _replaceAllPersonas(List<Persona> personas) async {
    final db = await _dbService.db;
    return await db.transaction((txn) async {
      await txn.delete('persona');
      if (personas.isEmpty) {
        return 0;
      }

      final batch = txn.batch();
      for (final persona in personas) {
        batch.insert(
          'persona',
          persona.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
      return personas.length;
    });
  }
}
