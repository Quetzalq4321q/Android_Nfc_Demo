// lib/services/nfc_guard.dart
import 'dart:async';

class NfcGuard {
  bool _busy = false;

  Future<T> run<T>(Future<T> Function() task) async {
    if (_busy) {
      // Evita 503 por sesión ocupada
      throw StateError('NFC ocupado: espera a que termine la operación actual');
    }
    _busy = true;
    try {
      return await task();
    } finally {
      _busy = false;
    }
  }
}
