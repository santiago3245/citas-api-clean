import 'package:flutter/material.dart';
import '../../models/medico.dart';
import '../../services/entities/medico_service.dart';
import 'medico_form_page.dart';

class MedicosListPage extends StatefulWidget {
  final bool embedded;
  const MedicosListPage({super.key, this.embedded = false});
  @override
  State<MedicosListPage> createState() => _MedicosListPageState();
}

class _MedicosListPageState extends State<MedicosListPage> {
  final _service = MedicoService();
  late Future<List<Medico>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.listar();
  }

  void _refresh() => setState(() => _future = _service.listar());

  Future<void> _openForm([Medico? m]) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MedicoFormPage(medico: m)),
    );
    if (changed == true && mounted) _refresh();
  }

  Future<void> _delete(Medico m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text('Eliminar médico ${m.nombre}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await _service.eliminar(m.id!);
        if (mounted) _refresh();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = FutureBuilder<List<Medico>>(
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
          if (data.isEmpty) return const Center(child: Text('Sin médicos'));
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (_, i) {
                final m = data[i];
                return Card(
                  child: ListTile(
                    title: Text('${m.nombre} ${m.apellido}'),
                    subtitle: Text([
                      m.especialidad,
                      if (m.email != null && m.email!.isNotEmpty) m.email!
                    ].join(' • ')),
                    onTap: () => _openForm(m),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _delete(m),
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
            const Text('Lista de Médicos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const Spacer(),
            FilledButton.icon(onPressed: () => _openForm(), icon: const Icon(Icons.add), label: const Text('Nuevo Médico')),
          ]),
          const SizedBox(height: 20),
          Expanded(child: content),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Médicos')),
      body: content,
      floatingActionButton: FloatingActionButton(onPressed: () => _openForm(), child: const Icon(Icons.add)),
    );
  }
}
