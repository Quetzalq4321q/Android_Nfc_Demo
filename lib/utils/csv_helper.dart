import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';

import '../models/persona.dart';
import 'id_utils.dart';

/// Convierte una lista de [Persona] en un CSV.
///
/// [includeHeader] indica si se debe incluir la fila de cabecera "id,nombre,grupo".
String personasToCsv(
  List<Persona> personas, {
  bool includeHeader = true,
}) {
  final rows = <List<dynamic>>[];
  if (includeHeader) {
    rows.add(const ['id', 'nombre', 'grupo']);
  }

  for (final persona in personas) {
    rows.add([persona.id, persona.nombre, persona.grupo]);
  }

  return const ListToCsvConverter().convert(rows);
}

/// Genera los bytes en UTF-8 de un CSV con la información de [personas].
Uint8List personasToCsvBytes(
  List<Persona> personas, {
  bool includeHeader = true,
  Encoding encoding = utf8,
}) {
  final csv = personasToCsv(personas, includeHeader: includeHeader);
  return encoding.encode(csv);
}

/// Lee el contenido CSV y lo convierte en una lista de [Persona].
///
/// El CSV debe contener columnas para `id`, `nombre` y `grupo`. Si [hasHeader] es
/// verdadero se tomará la primera fila como cabecera e identificará las columnas
/// por nombre. Si es falso se asumirán exactamente tres columnas en el orden
/// indicado.
List<Persona> personasFromCsv(
  String csvContent, {
  bool hasHeader = true,
}) {
  final trimmed = csvContent.trim();
  if (trimmed.isEmpty) return const [];

  final rows = const CsvToListConverter(
    shouldParseNumbers: false,
  ).convert(trimmed);

  if (rows.isEmpty) return const [];

  final personas = <Persona>[];
  int startRow = 0;
  List<String> headers = <String>[];

  if (hasHeader) {
    final headerRow = rows.first
        .map((value) => value?.toString().trim().toLowerCase() ?? '')
        .toList();

    final headerSet = headerRow.toSet();
    final expected = {'id', 'nombre', 'grupo'};
    if (!headerSet.containsAll(expected)) {
      throw const FormatException(
        'La cabecera del CSV debe incluir las columnas id, nombre y grupo',
      );
    }

    headers = headerRow;
    startRow = 1;
  } else {
    if (rows.first.length < 3) {
      throw const FormatException(
        'El CSV sin cabecera debe tener al menos 3 columnas por fila',
      );
    }
  }

  for (var i = startRow; i < rows.length; i++) {
    final row = rows[i];
    if (row.isEmpty) continue;

    final values = row.map((value) => value?.toString() ?? '').toList();
    if (values.every((v) => v.trim().isEmpty)) continue;

    String rawId;
    String nombre;
    String grupo;

    if (hasHeader) {
      final map = <String, String>{};
      for (var j = 0; j < headers.length && j < values.length; j++) {
        map[headers[j]] = values[j];
      }
      rawId = map['id'] ?? '';
      nombre = map['nombre'] ?? '';
      grupo = map['grupo'] ?? '';
    } else {
      rawId = values.length > 0 ? values[0] : '';
      nombre = values.length > 1 ? values[1] : '';
      grupo = values.length > 2 ? values[2] : '';
    }

    final normalizedId = normalizeId(rawId);
    if (normalizedId.isEmpty) {
      // Ignora filas sin un ID válido.
      continue;
    }

    personas.add(
      Persona(
        id: normalizedId,
        nombre: nombre.trim(),
        grupo: grupo.trim(),
      ),
    );
  }

  return personas;
}

/// Variante de [personasFromCsv] que acepta los bytes del archivo en UTF-8.
List<Persona> personasFromCsvBytes(
  Uint8List bytes, {
  bool hasHeader = true,
  Encoding encoding = utf8,
}) {
  final content = encoding.decode(bytes);
  return personasFromCsv(content, hasHeader: hasHeader);
}
