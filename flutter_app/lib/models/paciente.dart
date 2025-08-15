class Paciente {
  final int? id;
  final String nombre;
  final String apellido;
  final DateTime? fechaNacimiento; // puede venir null si no se envía
  final String email;

  Paciente({
    this.id,
    required this.nombre,
    required this.apellido,
    this.fechaNacimiento,
    required this.email,
  });

  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      fechaNacimiento: json['fechaNacimiento'] != null ? DateTime.parse(json['fechaNacimiento']) : null,
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'apellido': apellido,
      if (fechaNacimiento != null) 'fechaNacimiento': fechaNacimiento!.toIso8601String().split('T').first,
      'email': email,
    };
  }
}