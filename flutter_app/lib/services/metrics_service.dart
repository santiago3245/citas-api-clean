import 'api_service.dart';

class MetricsService {
  final ApiService _api;
  MetricsService({ApiService? api}) : _api = api ?? ApiService();

  Future<int> _count(String endpoint) async {
    final data = await _api.get(endpoint);
    if (data is List) return data.length;
    if (data is Map && data['content'] is List) return (data['content'] as List).length;
    return 0;
  }

  Future<int> pacientes() => _count('/pacientes');
  Future<int> medicos() => _count('/medicos');
  Future<int> consultorios() => _count('/consultorios');

  Future<int> citasHoy() async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final data = await _api.get('/citas');
    if (data is List) {
      return data.where((e) => (e['fecha'] ?? '').startsWith(today)).length;
    }
    return 0;
  }

  Future<List<Map<String, dynamic>>> proximasCitasHoy({int limit = 5}) async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final citasData = await _api.get('/citas');
    if (citasData is! List) return [];

    // Fetch referencias en paralelo
    final pacientesF = _api.get('/pacientes');
    final medicosF = _api.get('/medicos');
    final consultoriosF = _api.get('/consultorios');
    final refs = await Future.wait([pacientesF, medicosF, consultoriosF]);

    Map<int, String> pacMap = {};
    Map<int, String> medMap = {};
    Map<int, String> consMap = {};
    if (refs[0] is List) {
      for (final p in refs[0] as List) {
        final id = p['id'];
        if (id is int) pacMap[id] = p['nombre'] ?? p['name'] ?? 'Paciente $id';
      }
    }
    if (refs[1] is List) {
      for (final m in refs[1] as List) {
        final id = m['id'];
        if (id is int) medMap[id] = m['nombre'] ?? m['name'] ?? 'Médico $id';
      }
    }
    Map<int, String> consNumeroMap = {};
    if (refs[2] is List) {
      for (final c in refs[2] as List) {
        final id = c['id'];
        if (id is int) {
          consMap[id] = c['nombre'] ?? c['name'] ?? (c['numero'] != null ? 'Consultorio ${c['numero']}' : 'Consultorio $id');
          if (c['numero'] != null) consNumeroMap[id] = c['numero'].toString();
        }
      }
    }

    final filtered = citasData
        .where((e) => (e['fecha'] ?? '').startsWith(today) && (e['estado'] == null || e['estado'] == 'programada'))
        .toList();
    filtered.sort((a, b) => (a['hora'] ?? '').compareTo(b['hora'] ?? ''));

    return filtered.take(limit).map<Map<String, dynamic>>((raw) {
      final pid = raw['pacienteId'];
      final mid = raw['medicoId'];
      final cid = raw['consultorioId'];
      return {
        ...raw,
        'pacienteNombre': raw['pacienteNombre'] ?? (pid is int ? pacMap[pid] : null),
        'medicoNombre': raw['medicoNombre'] ?? (mid is int ? medMap[mid] : null),
        'consultorioNombre': raw['consultorioNombre'] ?? (cid is int ? consMap[cid] : null),
        if (cid is int && consNumeroMap[cid] != null) 'numero': consNumeroMap[cid],
      };
    }).toList();
  }
}
