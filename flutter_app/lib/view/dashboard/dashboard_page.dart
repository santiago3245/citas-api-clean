import 'package:flutter/material.dart';
import '../../services/metrics_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _metrics = MetricsService();
  late Future<_Stats> _future;
  List<Map<String, dynamic>> _citas = [];

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_Stats> _load() async {
    final pacientesF = _metrics.pacientes();
    final medicosF = _metrics.medicos();
    final citasHoyF = _metrics.citasHoy();
    final consultoriosF = _metrics.consultorios();
    final proximasF = _metrics.proximasCitasHoy(limit: 6);
    final results = await Future.wait([
      pacientesF, medicosF, citasHoyF, consultoriosF, proximasF
    ]);
    _citas = results[4] as List<Map<String, dynamic>>;
    return _Stats(
      pacientes: results[0] as int,
      medicos: results[1] as int,
      citasHoy: results[2] as int,
      consultorios: results[3] as int,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Stats>(
      future: _future,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Column(
            children: [
              Text('Error: ${snap.error}'),
              TextButton(onPressed: () => setState(() => _future = _load()), child: const Text('Reintentar')),
            ],
          );
        }
        final s = snap.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _StatCard(title: 'Pacientes Registrados', value: '${s.pacientes}', icon: Icons.people, color: const Color(0xFFBDD6FF)),
                _StatCard(title: 'Médicos Activos', value: '${s.medicos}', icon: Icons.person, color: const Color(0xFFC9F5DB)),
                _StatCard(title: 'Citas de Hoy', value: '${s.citasHoy}', icon: Icons.event, color: const Color(0xFFFFE1BB)),
                _StatCard(title: 'Consultorios', value: '${s.consultorios}', icon: Icons.meeting_room, color: const Color(0xFFE4D8FF)),
              ],
            ),
            const SizedBox(height: 32),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Próximas Citas (Hoy)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Actualizar',
                          icon: const Icon(Icons.refresh),
                          onPressed: () => setState(() { _future = _load(); }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_citas.isEmpty)
                      const Text('No hay citas programadas', style: TextStyle(color: Colors.black54))
                    else
                      Column(
                        children: _citas.map((c) => _CitaRow(c: c)).toList(),
                      ),
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

class _Stats {
  final int pacientes;
  final int medicos;
  final int citasHoy;
  final int consultorios;
  _Stats({required this.pacientes, required this.medicos, required this.citasHoy, required this.consultorios});
}

class _StatCard extends StatelessWidget {
  final String title; final String value; final IconData icon; final Color color;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 140,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87))),
                  Container(
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.all(10),
                    child: Icon(icon, size: 20, color: Colors.black87),
                  )
                ],
              ),
              const Spacer(),
              Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CitaRow extends StatelessWidget {
  final Map<String, dynamic> c;
  const _CitaRow({required this.c});
  @override
  Widget build(BuildContext context) {
    final hora = c['hora'] ?? '';
    final paciente = c['pacienteNombre'] ?? 'Paciente ${c['pacienteId'] ?? ''}';
    final medico = c['medicoNombre'] ?? 'Médico ${c['medicoId'] ?? ''}';
  final consultorio = c['consultorioNombre'] ?? (c['numero'] != null ? 'Consultorio ${c['numero']}' : 'Consultorio ${c['consultorioId'] ?? ''}');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE9E9EF)))
      ),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(hora, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(paciente)),
          Expanded(child: Text(medico)),
          Expanded(child: Text(consultorio)),
        ],
      ),
    );
  }
}
