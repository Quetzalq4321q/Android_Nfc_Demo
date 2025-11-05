// utils/id_utils.dart
import 'dart:typed_data';

String _bytesListToHex(List<int> bytes) {
  final sb = StringBuffer();
  for (final b in bytes) {
    sb.write(b.toRadixString(16).padLeft(2, '0'));
  }
  return sb.toString().toUpperCase();
}

/// Normaliza un ID de NFC a una representación HEX en mayúsculas (sin prefijo 0x).
///
/// Acepta varias entradas:
/// - Lista de bytes en texto: "[4, 57, 162, 195]" -> "0439A2C3"
/// - Hex string con/ sin mayúsculas y con/ sin separadores: "04:39:a2:c3" -> "0439A2C3"
/// - Número decimal en texto: "71145667" -> "0439A2C3" (convierte decimal->hex)
/// - Uint8List / List<int> (si lo envías desde código, conviértelo a string o usa la función privada)
String normalizeId(String? raw) {
  if (raw == null) return '';
  String s = raw.trim();

  // si es formato lista: [4, 57, 162]
  if (s.startsWith('[') && s.endsWith(']')) {
    final inside = s.substring(1, s.length - 1);
    final parts = inside.split(RegExp(r'\s*,\s*'));
    final bytes = <int>[];
    for (final p in parts) {
      final n = int.tryParse(p.replaceAll(RegExp(r'[^0-9\-]'), ''));
      if (n != null) bytes.add(n);
    }
    if (bytes.isNotEmpty) return _bytesListToHex(bytes);
  }

  // limpia separadores comunes (espacios, :, -)
  s = s.replaceAll(RegExp(r'[\s:\-]'), '');

  // si todo son dígitos => interpretarlo como decimal y convertir a hex
  if (RegExp(r'^[0-9]+$').hasMatch(s)) {
    try {
      final dec = BigInt.parse(s);
      final hex = dec.toRadixString(16);
      // asegurar pares de caracteres -> padLeft si es necesario
      final normalized = hex.length.isOdd ? '0$hex' : hex;
      return normalized.toUpperCase();
    } catch (_) {
      return s.toUpperCase();
    }
  }

  // si es hex (0-9 a-f) => solo normalizar mayúsculas y padding si necesario
  final hexCandidate = s.replaceAll(RegExp(r'^0x', caseSensitive: false), '');
  if (RegExp(r'^[0-9a-fA-F]+$').hasMatch(hexCandidate)) {
    final h = hexCandidate.length.isOdd ? '0$hexCandidate' : hexCandidate;
    return h.toUpperCase();
  }

  // fallback: devuelve la cadena en mayúsculas sin cambios significativos
  return s.toUpperCase();
}
