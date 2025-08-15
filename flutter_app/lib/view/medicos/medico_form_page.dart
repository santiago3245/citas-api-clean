import 'package:flutter/material.dart';
import '../../models/medico.dart';
import '../../services/entities/medico_service.dart';

class MedicoFormPage extends StatefulWidget {
  final Medico? medico;
  const MedicoFormPage({super.key, this.medico});

  @override
  State<MedicoFormPage> createState() => _MedicoFormPageState();
}

class _MedicoFormPageState extends State<MedicoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = MedicoService();
  late TextEditingController _nombre;
  late TextEditingController _apellido;
  late TextEditingController _especialidad;
  late TextEditingController _email; // opcional
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final m = widget.medico;
  _nombre = TextEditingController(text: m?.nombre);
  _apellido = TextEditingController(text: m?.apellido);
  _especialidad = TextEditingController(text: m?.especialidad);
  _email = TextEditingController(text: m?.email);
  }

  @override
  void dispose() {
  _nombre.dispose();
  _apellido.dispose();
  _especialidad.dispose();
  _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final m = Medico(
        id: widget.medico?.id,
        nombre: _nombre.text.trim(),
        apellido: _apellido.text.trim(),
        especialidad: _especialidad.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
      );
      if (widget.medico == null) {
        await _service.crear(m);
      } else {
        await _service.actualizar(m);
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
    final editing = widget.medico != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Editar Médico' : 'Nuevo Médico')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombre,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _apellido,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _especialidad,
                decoration: const InputDecoration(labelText: 'Especialidad'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email (opcional)'),
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
