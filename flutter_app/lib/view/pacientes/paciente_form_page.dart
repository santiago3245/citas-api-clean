import 'package:flutter/material.dart';
import '../../models/paciente.dart';
import '../../services/entities/paciente_service.dart';

class PacienteFormPage extends StatefulWidget {
  final Paciente? paciente;
  const PacienteFormPage({super.key, this.paciente});

  @override
  State<PacienteFormPage> createState() => _PacienteFormPageState();
}

class _PacienteFormPageState extends State<PacienteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = PacienteService();
  late TextEditingController _nombre;
  late TextEditingController _apellido;
  late TextEditingController _fechaNacimiento; // formato YYYY-MM-DD
  late TextEditingController _email;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
  _nombre = TextEditingController(text: widget.paciente?.nombre);
  _apellido = TextEditingController(text: widget.paciente?.apellido);
  _fechaNacimiento = TextEditingController(text: widget.paciente?.fechaNacimiento?.toIso8601String().split('T').first);
  _email = TextEditingController(text: widget.paciente?.email);
  }

  @override
  void dispose() {
  _nombre.dispose();
  _apellido.dispose();
  _fechaNacimiento.dispose();
  _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final p = Paciente(
        id: widget.paciente?.id,
        nombre: _nombre.text.trim(),
        apellido: _apellido.text.trim(),
        fechaNacimiento: _fechaNacimiento.text.trim().isEmpty ? null : DateTime.tryParse(_fechaNacimiento.text.trim()),
        email: _email.text.trim(),
      );
      if (widget.paciente == null) {
        await _service.crear(p);
      } else {
        await _service.actualizar(p);
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
    final editing = widget.paciente != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Editar Paciente' : 'Nuevo Paciente')),
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
                controller: _fechaNacimiento,
                decoration: const InputDecoration(labelText: 'Fecha Nacimiento (YYYY-MM-DD)'),
              ),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
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
