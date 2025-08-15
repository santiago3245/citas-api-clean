import '../api_service.dart';
import '../../models/cita.dart';

class CitaService {
  final ApiService _api;
  CitaService({ApiService? api}) : _api = api ?? ApiService();

  Future<List<Cita>> listar() async {
    final data = await _api.get('/citas');
    return (data as List).map((e) => Cita.fromJson(e)).toList();
  }

  Future<Cita> crear(Cita c) async {
    final data = await _api.post('/citas', c.toJson());
    return Cita.fromJson(data);
  }

  Future<Cita> actualizar(Cita c) async {
    final data = await _api.put('/citas/${c.id}', c.toJson());
    return Cita.fromJson(data);
  }

  Future<void> eliminar(int id) => _api.delete('/citas/$id');
}
