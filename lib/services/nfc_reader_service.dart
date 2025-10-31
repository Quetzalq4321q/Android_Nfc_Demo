// lib/services/nfc_reader_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart' as fnk;
import 'package:ndef/ndef.dart' as ndef;

class NfcReaderService {
  Future<bool> isNfcAvailableAndEnabled() async {
    final availability = await fnk.FlutterNfcKit.nfcAvailability;
    return availability == fnk.NFCAvailability.available;
  }

  Future<String?> readOneAsString() async {
    try {
      final tag = await fnk.FlutterNfcKit.poll(
        timeout: const Duration(seconds: 12),
        iosMultipleTagMessage: 'Coloca solo una etiqueta.',
        iosAlertMessage: 'Acerca tu credencial/etiqueta NFC.',
      );

      // ALTO NIVEL: List<ndef.NDEFRecord>
      final records = await fnk.FlutterNfcKit.readNDEFRecords();

      if (records.isNotEmpty) {
        final r = records.first;

        // 👉 IMPORTANTE: castear al subtipo correcto
        if (r is ndef.TextRecord) return r.text ?? '';
        if (r is ndef.UriRecord) return r.uri?.toString() ?? '';
        if (r is ndef.SmartPosterRecord) {
          final uri = r.uri?.toString(); // getter de SmartPosterRecord
          if (uri != null && uri.isNotEmpty) return uri;
          // tomar el primer título disponible
          final titles = r.titles; // Map<String?, String?>
          if (titles != null && titles.isNotEmpty) {
            return titles.values.first ?? '';
          }
        }

        // Fallback: payload plano si existe
        final payload = r.payload;
        if (payload != null && payload.isNotEmpty) {
          return utf8.decode(payload, allowMalformed: true);
        }
      }

      if (tag.id.isNotEmpty) return tag.id; // sin NDEF, UID
      return null;
    } on PlatformException {
      rethrow;
    } finally {
      try { await fnk.FlutterNfcKit.finish(); } catch (_) {}
    }
  }
}
