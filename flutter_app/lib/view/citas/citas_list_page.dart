import 'package:flutter/material.dart';
import '../../models/cita.dart';
import '../../services/entities/cita_service.dart';
import 'cita_form_page.dart';

class CitasListPage extends StatefulWidget {
  final bool embedded;
  const CitasListPage({super.key, this.embedded = false});
  @override
  State<CitasListPage> createState() => _CitasListPageState();
}

class _CitasListPageState extends State<CitasListPage> {
  final _service = CitaService();
  late Future<List<Cita>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.listar();
  }

  void _refresh() {
    setState(() {
      _future = _service.listar();
    });
  }

  Future<void> _openForm([Cita? c]) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CitaFormPage(cita: c)),
    );
    if (changed == true && mounted) _refresh();
  }

  Future<void> _delete(Cita c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text('Eliminar cita #${c.id}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok == true && c.id != null) {
      try {
        await _service.eliminar(c.id!);
        if (mounted) _refresh();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  String _info(Cita c) => '${c.fecha.toIso8601String().split('T')[0]} ${c.hora}';

  @override
  Widget build(BuildContext context) {
    final content = FutureBuilder<List<Cita>>(
        future: _future,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Error: ${snap.error}', style: const TextStyle(color: Colors.red)),
              TextButton(onPressed: _refresh, child: const Text('Reintentar')),
            ]));
          }
          final data = snap.data ?? [];
            if (data.isEmpty) return const Center(child: Text('Sin citas'));
            return RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: data.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (_, i) {
                  final c = data[i];
                  return Card(
                    child: ListTile(
                      title: Text('Paciente ${c.pacienteId} - Médico ${c.medicoId}'),
                      subtitle: Text('${_info(c)} • Consultorio ${c.consultorioId}'),
                      onTap: () => _openForm(c),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _delete(c),
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
          Row(children: [
            const Text('Lista de Citas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const Spacer(),
            FilledButton.icon(onPressed: () => _openForm(), icon: const Icon(Icons.add), label: const Text('Nueva Cita')),
          ]),
          const SizedBox(height: 20),
          Expanded(child: content),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Citas')),
      body: content,
      floatingActionButton: FloatingActionButton(onPressed: () => _openForm(), child: const Icon(Icons.add)),
    );
  }
}
