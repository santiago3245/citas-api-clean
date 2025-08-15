class Medico {
  final int? id;
  final String nombre;
  final String apellido;
  final String especialidad;
  final String? email; // email puede no estar aún en backend (no aparece en entidad)

  Medico({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.especialidad,
    this.email,
  });

  factory Medico.fromJson(Map<String, dynamic> json) {
    return Medico(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      especialidad: json['especialidad'] ?? '',
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'especialidad': especialidad,
      if (email != null) 'email': email,
    };
  }
}