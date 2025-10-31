// lib/services/nfc_service.dart
import 'dart:convert';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart' as fnk;
import 'package:ndef/ndef.dart' as ndef;

/// Servicio NFC usando flutter_nfc_kit + ndef (alto nivel).
class NfcService {
  Future<bool> isNfcAvailableAndEnabled() async {
    final availability = await fnk.FlutterNfcKit.nfcAvailability;
    return availability == fnk.NFCAvailability.available;
  }

  /// Lee una etiqueta: devuelve texto/URI NDEF o UID físico.
  Future<String?> readNfc() async {
    try {
      final fnk.NFCTag tag = await fnk.FlutterNfcKit.poll(
        timeout: const Duration(seconds: 10),
        iosMultipleTagMessage: 'Coloca solo una tarjeta NFC.',
        iosAlertMessage: 'Acerca tu credencial o etiqueta NFC al dispositivo.',
      );

      // LEE **DECODIFICADO** como modelos de alto nivel:
      // List<ndef.NDEFRecord>
      final List<ndef.NDEFRecord> records =
      await fnk.FlutterNfcKit.readNDEFRecords();

      if (records.isNotEmpty) {
        final ndef.NDEFRecord r = records.first;

        if (r is ndef.TextRecord) {
          return r.text ?? '';
        }

        if (r is ndef.UriRecord) {
          return r.uri?.toString() ?? '';
        }

        // Fallback genérico: intenta decodificar el payload como UTF-8
        final payload = r.payload;
        if (payload != null && payload.isNotEmpty) {
          return utf8.decode(payload, allowMalformed: true);
        }
      }

      // Sin NDEF: devolver UID
      if (tag.id.isNotEmpty) return tag.id;

      return null;
    } finally {
      await fnk.FlutterNfcKit.finish();
    }
  }

  /// Escribe un NDEF **de texto** usando ndef.TextRecord (alto nivel).
  Future<void> writeIdAsNdef(String id) async {
    try {
      await fnk.FlutterNfcKit.poll(
        timeout: const Duration(seconds: 10),
        iosAlertMessage: 'Acerca una etiqueta NFC vacía para escribir.',
      );

      // Construye el modelo de alto nivel:
      final ndef.TextRecord textRec = ndef.TextRecord(text: id);

      // Escríbelo DIRECTO: acepta List<ndef.NDEFRecord>
      await fnk.FlutterNfcKit.writeNDEFRecords([textRec]);
    } finally {
      await fnk.FlutterNfcKit.finish();
    }
  }
}
