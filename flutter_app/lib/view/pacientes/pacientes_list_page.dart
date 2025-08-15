import 'package:flutter/material.dart';
import '../../models/paciente.dart';
import '../../services/entities/paciente_service.dart';
import 'paciente_form_page.dart';

class PacientesListPage extends StatefulWidget {
  final bool embedded; // si está dentro del shell no mostramos Scaffold
  const PacientesListPage({super.key, this.embedded = false});
  @override
  State<PacientesListPage> createState() => _PacientesListPageState();
}

class _PacientesListPageState extends State<PacientesListPage> {
  final _service = PacienteService();
  late Future<List<Paciente>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.listar();
  }

  void _refresh() {
    // No devolver Future dentro de setState; solo reasignamos el Future.
    setState(() {
      _future = _service.listar();
    });
  }

  Future<void> _openForm([Paciente? p]) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PacienteFormPage(paciente: p)),
    );
    if (changed == true && mounted) _refresh();
  }

  Future<void> _delete(Paciente p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text('Eliminar paciente ${p.nombre}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await _service.eliminar(p.id!);
        if (mounted) _refresh();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = FutureBuilder<List<Paciente>>(
        future: _future,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Error: ${snap.error}', style: const TextStyle(color: Colors.red)),
                TextButton(onPressed: _refresh, child: const Text('Reintentar')),
              ]),
            );
          }
          final data = snap.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text('Sin pacientes'));
          }
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (_, i) {
                final p = data[i];
                return Card(
                  child: ListTile(
                    title: Text('${p.nombre} ${p.apellido}'),
                    subtitle: Text([
                      if (p.fechaNacimiento != null) 'Nac: ${p.fechaNacimiento!.toIso8601String().split('T').first}',
                      p.email
                    ].where((e) => e.isNotEmpty).join(' • ')),
                    onTap: () => _openForm(p),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _delete(p),
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('Lista de Pacientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const Spacer(),
              FilledButton.icon(onPressed: () => _openForm(), icon: const Icon(Icons.add), label: const Text('Nuevo Paciente')),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(child: content),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Pacientes')),
      body: content,
      floatingActionButton: FloatingActionButton(onPressed: () => _openForm(), child: const Icon(Icons.add)),
    );
  }
}
