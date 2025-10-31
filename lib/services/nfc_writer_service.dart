// lib/services/nfc_writer_service.dart
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart' as fnk;
import 'package:ndef/ndef.dart' as ndef;

class NfcWriterService {
  Future<void> writeText(String text, {String lang = 'es'}) async {
    await _withSession(() async {
      final rec = ndef.TextRecord(text: text, language: lang);
      await fnk.FlutterNfcKit.writeNDEFRecords([rec]);
    });
  }

  Future<void> writeUri(String url) async {
    await _withSession(() async {
      final rec = ndef.UriRecord.fromString(url);
      await fnk.FlutterNfcKit.writeNDEFRecords([rec]);
    });
  }

  /// ✅ OPCIÓN A (simple): constructor normal con `title` y `uri`
  Future<void> writeSmartPoster({
    required String url,
    String? title,
  }) async {
    await _withSession(() async {
      final sp = ndef.SmartPosterRecord(
        uri: Uri.parse(url), // usa `uri:` del SmartPosterRecord
        title: title,        // un solo título (inglés por defecto)
      );
      await fnk.FlutterNfcKit.writeNDEFRecords([sp]);
    });
  }

  /// ✅ OPCIÓN B (lista): usar `fromList` con varios títulos/URIs si quieres
  Future<void> writeSmartPosterFromList({
    required String url,
    String? titleEs,
    String? titleEn,
  }) async {
    await _withSession(() async {
      final titles = <ndef.TextRecord>[
        if (titleEs != null && titleEs.isNotEmpty)
          ndef.TextRecord(text: titleEs, language: 'es'),
        if (titleEn != null && titleEn.isNotEmpty)
          ndef.TextRecord(text: titleEn, language: 'en'),
      ];
      final sp = ndef.SmartPosterRecord.fromList(
        titleRecords: titles,
        uriRecords: [ndef.UriRecord.fromString(url)],
      );
      await fnk.FlutterNfcKit.writeNDEFRecords([sp]);
    });
  }

  /// ✅ AAR correcto (no `ExternalTypeRecord`)
  Future<void> writeAar(String packageName) async {
    await _withSession(() async {
      final aar = ndef.AARRecord(packageName: packageName);
      await fnk.FlutterNfcKit.writeNDEFRecords([aar]);
    });
  }

  // ---- sesión segura ----
  Future<void> _withSession(Future<void> Function() body) async {
    try {
      await fnk.FlutterNfcKit.poll(
        timeout: const Duration(seconds: 12),
        iosAlertMessage: 'Acerca una etiqueta NDEF para escribir.',
      );
      await body();
    } on PlatformException {
      rethrow;
    } finally {
      try { await fnk.FlutterNfcKit.finish(); } catch (_) {}
    }
  }
}
