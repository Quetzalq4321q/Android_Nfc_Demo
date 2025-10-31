/// Modelo de datos para un registro de log.
class LogEntry {
  final int? id;
  final String tagId;
  final String fecha;
  final String resultado;

  LogEntry({
    this.id,
    required this.tagId,
    required this.fecha,
    required this.resultado,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tag_id': tagId,
      'fecha': fecha,
      'resultado': resultado,
    };
  }

  factory LogEntry.fromMap(Map<String, dynamic> map) {
    return LogEntry(
      id: map['id'],
      tagId: map['tag_id'],
      fecha: map['fecha'],
      resultado: map['resultado'],
    );
  }
}
