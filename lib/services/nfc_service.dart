// lib/services/nfc_service.dart
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/ndef.dart' as ndef;

/// Servicio NFC compatible con flutter_nfc_kit 3.6.0 + ndef 0.3.4
class NfcService {
  Future<bool> isNfcAvailableAndEnabled() async {
    try {
      final availability = await FlutterNfcKit.nfcAvailability;
      return availability == NFCAvailability.available;
    } catch (e) {
      return false;
    }
  }

  /// Lee UID (tag.id)
  Future<String?> readNfc({Duration timeout = const Duration(seconds: 12)}) async {
    try {
      final tag = await FlutterNfcKit.poll(
        timeout: timeout,
        iosMultipleTagMessage: 'Multiple tags found',
        iosAlertMessage: 'Acerca la etiqueta NFC',
      );
      final id = tag.id;
      await FlutterNfcKit.finish();
      return id;
    } catch (e) {
      try { await FlutterNfcKit.finish(); } catch (_) {}
      rethrow;
    }
  }

  /// Lee el primer registro NDEF (si existe) y devuelve String (URI o Text)
  Future<String?> readFirstNdefPayload({Duration timeout = const Duration(seconds: 12)}) async {
    try {
      final tag = await FlutterNfcKit.poll(
        timeout: timeout,
        iosMultipleTagMessage: 'Multiple tags found',
        iosAlertMessage: 'Acerca la etiqueta NFC',
      );

      String? result;
      if (tag.ndefAvailable == true) {
        final records = await FlutterNfcKit.readNDEFRecords(cached: false);
        if (records.isNotEmpty) {
          final rec = records.first;
          if (rec is ndef.UriRecord) {
            result = rec.uri?.toString();
          } else if (rec is ndef.TextRecord) {
            result = rec.text;
          } else {
            result = rec.toString();
          }
        }
      }

      await FlutterNfcKit.finish();
      return result;
    } catch (e) {
      try { await FlutterNfcKit.finish(); } catch (_) {}
      rethrow;
    }
  }

  /// Escribe la ID como URI (urn:uuid:<id>) — más robusto que texto crudo
  Future<void> writeIdAsUri(String idToWrite, {Duration timeout = const Duration(seconds: 12)}) async {
    try {
      await FlutterNfcKit.poll(
        timeout: timeout,
        iosMultipleTagMessage: 'Multiple tags found',
        iosAlertMessage: 'Acerca la etiqueta para escribir',
      );
      final uriRecord = ndef.UriRecord.fromString('urn:uuid:$idToWrite');
      await FlutterNfcKit.writeNDEFRecords([uriRecord]);
      await FlutterNfcKit.finish(iosAlertMessage: 'ID escrita: $idToWrite');
    } catch (e) {
      try { await FlutterNfcKit.finish(iosErrorMessage: 'Error escribiendo'); } catch (_) {}
      rethrow;
    }
  }

  /// Alternativa: escribe texto plano como TextRecord
  Future<void> writeIdAsText(String idToWrite, {Duration timeout = const Duration(seconds: 12)}) async {
    try {
      await FlutterNfcKit.poll(
        timeout: timeout,
        iosMultipleTagMessage: 'Multiple tags found',
        iosAlertMessage: 'Acerca la etiqueta para escribir',
      );
      final textRecord = ndef.TextRecord(text: idToWrite, language: 'en');
      await FlutterNfcKit.writeNDEFRecords([textRecord]);
      await FlutterNfcKit.finish(iosAlertMessage: 'Texto escrito: $idToWrite');
    } catch (e) {
      try { await FlutterNfcKit.finish(iosErrorMessage: 'Error escribiendo'); } catch (_) {}
      rethrow;
    }
  }
}
