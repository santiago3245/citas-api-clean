import '../api_service.dart';
import '../../models/paciente.dart';

class PacienteService {
  final ApiService _api;
  PacienteService({ApiService? api}) : _api = api ?? ApiService();

  Future<List<Paciente>> listar() async {
    final data = await _api.get('/pacientes');
    return (data as List).map((e) => Paciente.fromJson(e)).toList();
  }

  Future<Paciente> crear(Paciente p) async {
    final data = await _api.post('/pacientes', p.toJson());
    return Paciente.fromJson(data);
  }

  Future<Paciente> actualizar(Paciente p) async {
    final data = await _api.put('/pacientes/${p.id}', p.toJson());
    return Paciente.fromJson(data);
  }

  Future<void> eliminar(int id) => _api.delete('/pacientes/$id');
}
