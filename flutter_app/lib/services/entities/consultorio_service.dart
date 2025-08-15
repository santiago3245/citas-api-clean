import '../api_service.dart';
import '../../models/consultorio.dart';

class ConsultorioService {
  final ApiService _api;
  ConsultorioService({ApiService? api}) : _api = api ?? ApiService();

  Future<List<Consultorio>> listar() async {
    final data = await _api.get('/consultorios');
    return (data as List).map((e) => Consultorio.fromJson(e)).toList();
  }

  Future<Consultorio> crear(Consultorio c) async {
    final data = await _api.post('/consultorios', c.toJson());
    return Consultorio.fromJson(data);
  }

  Future<Consultorio> actualizar(Consultorio c) async {
    final data = await _api.put('/consultorios/${c.id}', c.toJson());
    return Consultorio.fromJson(data);
  }

  Future<void> eliminar(int id) => _api.delete('/consultorios/$id');
}
