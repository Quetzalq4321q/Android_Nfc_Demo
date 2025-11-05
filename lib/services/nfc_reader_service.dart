import 'nfc_service.dart';

class NfcReaderService {
  final NfcService _nfc;

  NfcReaderService({NfcService? nfc}) : _nfc = nfc ?? NfcService();

  /// Lee el primer NDEF texto/URI o, si no hay, el UID físico.
  Future<String?> readId() => _nfc.readNfc();
}
