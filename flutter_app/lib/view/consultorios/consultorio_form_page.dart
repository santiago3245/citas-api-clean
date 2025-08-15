import 'package:flutter/material.dart';
import '../../models/consultorio.dart';
import '../../services/entities/consultorio_service.dart';

class ConsultorioFormPage extends StatefulWidget {
  final Consultorio? consultorio;
  const ConsultorioFormPage({super.key, this.consultorio});

  @override
  State<ConsultorioFormPage> createState() => _ConsultorioFormPageState();
}

class _ConsultorioFormPageState extends State<ConsultorioFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = ConsultorioService();
  late TextEditingController _numero;
  late TextEditingController _piso;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
  final c = widget.consultorio;
  _numero = TextEditingController(text: c?.numero);
  _piso = TextEditingController(text: c?.piso?.toString());
  }

  @override
  void dispose() {
  _numero.dispose();
  _piso.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final c = Consultorio(
        id: widget.consultorio?.id,
        numero: _numero.text.trim(),
        piso: int.tryParse(_piso.text.trim()),
      );
      if (widget.consultorio == null) {
        await _service.crear(c);
      } else {
        await _service.actualizar(c);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.consultorio != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Editar Consultorio' : 'Nuevo Consultorio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _numero,
                decoration: const InputDecoration(labelText: 'Número (único)'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _piso,
                decoration: const InputDecoration(labelText: 'Piso'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(_saving ? 'Guardando...' : 'Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
