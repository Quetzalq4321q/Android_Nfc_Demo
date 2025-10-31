import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../services/nfc_service.dart';
import '../services/persona_service.dart';
import '../models/persona.dart';

/// Provider que coordina lectura/escritura NFC y persistencia en BD.
/// Expone estado para la UI (status, persona encontrada, último ID, etc).
class NfcProvider extends ChangeNotifier {
  final NfcService _nfcService = NfcService();
  final PersonaService _personaService = PersonaService();

  String status = 'Listo';
  Persona? foundPersona;
  String? lastId;

  /// Limpia el estado del proveedor
  void clear() {
    status = 'Listo';
    foundPersona = null;
    lastId = null;
    notifyListeners();
  }

  /// Lee una etiqueta NFC (NDEF texto/URI o UID) y busca la persona en la BD.
  Future<void> startRead() async {
    status = 'Esperando etiqueta NFC...';
    foundPersona = null;
    notifyListeners();

    final disponible = await _nfcService.isNfcAvailableAndEnabled();
    if (!disponible) {
      status = 'NFC no disponible o desactivado';
      notifyListeners();
      return;
    }

    try {
      final id = await _nfcService.readNfc();
      if (id == null || id.isEmpty) {
        status = 'No se pudo leer ID del tag';
        notifyListeners();
        return;
      }

      lastId = id;
      status = 'ID leído: $id — buscando en base de datos...';
      notifyListeners();

      final persona = await _personaService.getPersonaById(id);
      if (persona != null) {
        foundPersona = persona;
        status = 'Encontrado: ${persona.nombre} (${persona.grupo ?? '-'})';
      } else {
        foundPersona = null;
        status = 'ID no registrado: $id';
      }
      notifyListeners();
    } on PlatformException catch (e) {
      // Errores específicos del stack NFC (timeout, bloqueo, etc.)
      status = 'Error al leer NFC: ${_friendlyPlatformMessage(e)}';
      notifyListeners();
    } catch (e) {
      status = 'Error al leer NFC: ${_friendlyMessage(e)}';
      notifyListeners();
    }
  }

  /// Escribe un ID como NDEF de texto y guarda/actualiza el registro en la BD.
  Future<void> writeAndSave(
      String id,
      String nombre,
      String grupo, {
        required void Function(String) onError,
        required void Function() onSuccess,
      }) async {
    status = 'Acerca una etiqueta NFC para escribir...';
    notifyListeners();

    try {
      // 1) Escribir NDEF en la etiqueta
      await _nfcService.writeIdAsNdef(id);

      // 2) Guardar en base de datos
      final persona = Persona(id: id, nombre: nombre, grupo: grupo);
      await _personaService.insertOrReplacePersona(persona);

      // 3) Actualizar estado UI
      foundPersona = persona;
      lastId = id;
      status = 'Etiqueta escrita y guardada: $nombre';
      notifyListeners();
      onSuccess();
    } on PlatformException catch (e) {
      // Captura de errores NFC con códigos comunes (408, 409, etc.)
      final friendly = _friendlyPlatformMessage(e);
      status = 'Error al escribir: $friendly';
      notifyListeners();
      onError(friendly);
    } catch (e) {
      final friendly = _friendlyMessage(e);
      status = 'Error al escribir: $friendly';
      notifyListeners();
      onError(friendly);
    }
  }

  // -------------------------
  // Helpers de mensajes
  // -------------------------

  String _friendlyPlatformMessage(PlatformException e) {
    // Códigos típicos: 408 (timeout), 409 (conflicto/etiqueta bloqueada), otros
    switch (e.code) {
      case '408':
        return 'Tiempo agotado. Mantén la tarjeta pegada y sin mover hasta que termine.';
      case '409':
        return 'No se pudo escribir: la etiqueta puede estar bloqueada o no soporta NDEF.';
      default:
      // Mensaje genérico incluyendo el código para depurar si es necesario
        final msg = (e.message ?? '').trim();
        return msg.isNotEmpty ? '(${e.code}) $msg' : 'Error NFC (${e.code}).';
    }
  }

  String _friendlyMessage(Object e) {
    final s = e.toString();
    if (s.contains('bloqueada') || s.toLowerCase().contains('ndef')) {
      return 'La etiqueta no se puede escribir (bloqueada o no NDEF). Prueba con otra.';
    }
    if (s.contains('Timeout') || s.contains('tiempo') || s.contains('agotado')) {
      return 'Tiempo agotado. Mantén la tarjeta pegada y sin mover hasta que termine.';
    }
    return s;
  }
}
