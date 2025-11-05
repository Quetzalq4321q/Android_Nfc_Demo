import 'nfc_service.dart';

class NfcWriterService {
  final NfcService _nfc;

  NfcWriterService({NfcService? nfc}) : _nfc = nfc ?? NfcService();

  /// Escribe el id como NDEF de texto.
  Future<void> writeId(String id) => _nfc.writeIdAsNdef(id);
}
