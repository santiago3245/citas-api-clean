class Consultorio {
  final int? id;
  final String numero;
  final int? piso;

  Consultorio({
    this.id,
    required this.numero,
    this.piso,
  });

  factory Consultorio.fromJson(Map<String, dynamic> json) {
    return Consultorio(
      id: json['id'],
      numero: json['numero'] ?? '',
      piso: json['piso'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'numero': numero,
      if (piso != null) 'piso': piso,
    };
  }
}
