import 'package:flutter/material.dart';
import '../models/persona.dart';
import '../services/log_service.dart';
import '../services/nfc_service.dart';
import '../services/persona_service.dart';

/// Provider que coordina la lectura y escritura NFC con el servicio de base de datos.
/// Gestiona el estado visible en la interfaz de usuario (status, persona encontrada, etc.)
class NfcProvider extends ChangeNotifier {
  NfcProvider({
    required NfcService nfcService,
    required PersonaService personaService,
    required LogService logService,
  })  : _nfcService = nfcService,
        _personaService = personaService,
        _logService = logService;

  final NfcService _nfcService;
  final PersonaService _personaService;
  final LogService _logService;

  String status = 'Listo para leer';
  Persona? foundPersona;
  String? lastId;
  String? failureReason;
  Color backgroundColor = Colors.white;
  bool isProcessing = false;

  /// Limpia el estado del proveedor
  void clear() {
    status = 'Listo para leer';
    foundPersona = null;
    lastId = null;
    failureReason = null;
    backgroundColor = Colors.white;
    isProcessing = false;
    notifyListeners();
  }

  /// Ejecuta el flujo completo de lectura, validación y registro de logs.
  Future<void> comprobarNfcYRegistrar() async {
    isProcessing = true;
    status = 'Esperando etiqueta NFC...';
    backgroundColor = Colors.white;
    foundPersona = null;
    failureReason = null;
    lastId = null;
    notifyListeners();

    final disponible = await _nfcService.isNfcAvailableAndEnabled();
    if (!disponible) {
      isProcessing = false;
      status = 'NFC no disponible o desactivado';
      backgroundColor = Colors.red.shade100;
      failureReason = status;
      notifyListeners();
      await _logService.insertLog('SIN_DISPONIBILIDAD', 'NFC desactivado');
      return;
    }

    try {
      final id = await _nfcService.readNfc();
      if (id == null || id.isEmpty) {
        isProcessing = false;
        status = 'No se detectó ID en la etiqueta';
        backgroundColor = Colors.red.shade100;
        failureReason = status;
        notifyListeners();
        await _logService.insertLog('SIN_ID', 'Etiqueta sin ID');
        return;
      }

      lastId = id;
      final persona = await _personaService.getPersonaById(id);

      if (persona != null) {
        foundPersona = persona;
        status = 'Encontrado: ${persona.nombre} • ${persona.grupo}';
        backgroundColor = Colors.green.shade100;
        failureReason = null;
        isProcessing = false;
        notifyListeners();
        await _logService.insertLog(id, 'Verificación correcta');
        return;
      }

      foundPersona = null;
      status = 'ID no registrada: $id';
      backgroundColor = Colors.red.shade100;
      failureReason = 'ID no registrada';
      isProcessing = false;
      notifyListeners();
      await _logService.insertLog(id, 'ID no registrada');
    } catch (e) {
      isProcessing = false;
      status = 'Error al leer NFC: $e';
      backgroundColor = Colors.red.shade100;
      failureReason = status;
      notifyListeners();
      await _logService.insertLog('ERROR', 'Error al leer NFC: $e');
    }
  }

  /// Escribe un ID en una etiqueta NFC y lo guarda en la base de datos.
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
      await _nfcService.writeIdAsNdef(id);

      // Guarda o actualiza persona en base de datos
      final persona = Persona(id: id, nombre: nombre, grupo: grupo);
      await _personaService.insertOrReplacePersona(persona);

      foundPersona = persona;
      lastId = id;
      status = 'Etiqueta escrita y guardada: $nombre';
      notifyListeners();
      onSuccess();
    } catch (e) {
      status = 'Error al escribir: $e';
      notifyListeners();
      onError(e.toString());
    }
  }
}
