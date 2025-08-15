import '../api_service.dart';
import '../../models/medico.dart';

class MedicoService {
  final ApiService _api;
  MedicoService({ApiService? api}) : _api = api ?? ApiService();

  Future<List<Medico>> listar() async {
    final data = await _api.get('/medicos');
    return (data as List).map((e) => Medico.fromJson(e)).toList();
  }

  Future<Medico> crear(Medico m) async {
    final data = await _api.post('/medicos', m.toJson());
    return Medico.fromJson(data);
  }

  Future<Medico> actualizar(Medico m) async {
    final data = await _api.put('/medicos/${m.id}', m.toJson());
    return Medico.fromJson(data);
  }

  Future<void> eliminar(int id) => _api.delete('/medicos/$id');
}
