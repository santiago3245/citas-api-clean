import 'package:flutter/material.dart';
import '../../models/cita.dart';
import '../../models/paciente.dart';
import '../../models/medico.dart';
import '../../models/consultorio.dart';
import '../../services/entities/cita_service.dart';
import '../../services/entities/paciente_service.dart';
import '../../services/entities/medico_service.dart';
import '../../services/entities/consultorio_service.dart';

class CitaFormPage extends StatefulWidget {
  final Cita? cita;
  const CitaFormPage({super.key, this.cita});

  @override
  State<CitaFormPage> createState() => _CitaFormPageState();
}

class _CitaFormPageState extends State<CitaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = CitaService();
  final _pacienteSrv = PacienteService();
  final _medicoSrv = MedicoService();
  final _consultorioSrv = ConsultorioService();
  List<Paciente> _pacientes = [];
  List<Medico> _medicos = [];
  List<Consultorio> _consultorios = [];
  int? _pacienteId;
  int? _medicoId;
  int? _consultorioId;
  late TextEditingController _hora;
  // Eliminado estado; backend no lo maneja actualmente
  DateTime _fecha = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.cita;
  _pacienteId = c?.pacienteId;
  _medicoId = c?.medicoId;
  _consultorioId = c?.consultorioId;
  _hora = TextEditingController(text: c?.hora ?? '09:00');
    if (c != null) _fecha = c.fecha;
  _loadRefs();
  }

  @override
  void dispose() {
    _hora.dispose();
    super.dispose();
  }

  Future<void> _loadRefs() async {
    try {
      final results = await Future.wait([
        _pacienteSrv.listar(),
        _medicoSrv.listar(),
        _consultorioSrv.listar(),
      ]);
      if (!mounted) return;
      setState(() {
        _pacientes = results[0] as List<Paciente>;
        _medicos = results[1] as List<Medico>;
        _consultorios = results[2] as List<Consultorio>;
        // Asegurar selección por defecto si está vacío
        _pacienteId ??= _pacientes.isNotEmpty ? _pacientes.first.id : null;
        _medicoId ??= _medicos.isNotEmpty ? _medicos.first.id : null;
        _consultorioId ??= _consultorios.isNotEmpty ? _consultorios.first.id : null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cargando referencias: $e')));
      }
    }
  }

  Future<void> _pickFecha() async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _fecha,
    );
    if (d != null) {
      setState(() => _fecha = d);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final c = Cita(
        id: widget.cita?.id,
  pacienteId: _pacienteId!,
  medicoId: _medicoId!,
  consultorioId: _consultorioId!,
  fecha: _fecha,
  hora: _hora.text.trim(),
      );
      if (widget.cita == null) {
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
    final editing = widget.cita != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Editar Cita' : 'Nueva Cita')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(children: [
                Expanded(child: Text('Fecha: ${_fecha.toIso8601String().split('T')[0]}')),
                TextButton.icon(onPressed: _pickFecha, icon: const Icon(Icons.calendar_today), label: const Text('Cambiar')),
              ]),
              TextFormField(
                controller: _hora,
                decoration: const InputDecoration(labelText: 'Hora (HH:MM)'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              DropdownButtonFormField<int>(
                value: _pacienteId,
                decoration: const InputDecoration(labelText: 'Paciente'),
                items: _pacientes.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombre))).toList(),
                onChanged: (v) => setState(() => _pacienteId = v),
                validator: (v) => v == null ? 'Requerido' : null,
              ),
              DropdownButtonFormField<int>(
                value: _medicoId,
                decoration: const InputDecoration(labelText: 'Médico'),
                items: _medicos.map((m) => DropdownMenuItem(value: m.id, child: Text(m.nombre))).toList(),
                onChanged: (v) => setState(() => _medicoId = v),
                validator: (v) => v == null ? 'Requerido' : null,
              ),
              DropdownButtonFormField<int>(
                value: _consultorioId,
                decoration: const InputDecoration(labelText: 'Consultorio'),
                items: _consultorios.map((c) => DropdownMenuItem(value: c.id, child: Text('Consultorio ${c.numero}'))).toList(),
                onChanged: (v) => setState(() => _consultorioId = v),
                validator: (v) => v == null ? 'Requerido' : null,
              ),
              // Estado eliminado del formulario
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
