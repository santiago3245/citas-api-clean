class Cita {
  final int? id;
  final int pacienteId;
  final int medicoId;
  final int consultorioId;
  final DateTime fecha;
  final String hora; // HH:MM

  Cita({
    this.id,
    required this.pacienteId,
    required this.medicoId,
    required this.consultorioId,
    required this.fecha,
    required this.hora,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: json['id'],
      pacienteId: json['pacienteId'],
      medicoId: json['medicoId'],
      consultorioId: json['consultorioId'],
      fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : DateTime.now(),
      hora: (json['hora'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'pacienteId': pacienteId,
      'medicoId': medicoId,
      'consultorioId': consultorioId,
      'fecha': fecha.toIso8601String().split('T').first,
      'hora': hora,
    };
  }
}