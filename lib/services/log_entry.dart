class LogEntry {
  final int? id;          // autoincrement
  final String tagId;
  final String fecha;     // ISO 8601
  final String resultado; // "permitido" / "denegado" / "denegado: sin tag"

  LogEntry({
    this.id,
    required this.tagId,
    required this.fecha,
    required this.resultado,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'tag_id': tagId,
    'fecha': fecha,
    'resultado': resultado,
  }..removeWhere((k, v) => v == null);

  factory LogEntry.fromMap(Map<String, dynamic> map) => LogEntry(
    id: map['id'] as int?,
    tagId: map['tag_id'] as String,
    fecha: map['fecha'] as String,
    resultado: map['resultado'] as String,
  );
}
