import 'package:flutter/material.dart';
import '../services/nfc_service.dart';
import '../services/persona_service.dart';
import '../models/persona.dart';

/// Provider que coordina la lectura y escritura NFC con el servicio de base de datos.
/// Gestiona el estado visible en la interfaz de usuario (status, persona encontrada, etc.)
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

  /// Inicia la lectura NFC usando la nueva API basada en Future
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
        status = 'Encontrado: ${persona.nombre} (${persona.grupo})';
      } else {
        foundPersona = null;
        status = 'ID no registrado: $id';
      }
      notifyListeners();
    } catch (e) {
      status = 'Error al leer NFC: $e';
      notifyListeners();
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
