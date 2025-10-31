import 'package:flutter/material.dart';

Color colorPorTipo(String tipo) {
  switch (tipo) {
    case 'alumno':
      return Colors.green.shade700;
    case 'docente':
      return Colors.blue.shade700;
    case 'administrador':
      return Colors.orange.shade700;
    default:
      return Colors.red.shade700;
  }
}
