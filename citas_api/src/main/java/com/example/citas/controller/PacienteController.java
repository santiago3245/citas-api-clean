package com.example.citas.controller;

import com.example.citas.dto.PacienteDTO;
import com.example.citas.service.PacienteServicio;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/pacientes")
public class PacienteController {

    private final PacienteServicio pacienteServicio;

    public PacienteController(PacienteServicio pacienteServicio) {
        this.pacienteServicio = pacienteServicio;
    }

    @GetMapping
    public ResponseEntity<List<PacienteDTO>> obtenerTodos() {
        return ResponseEntity.ok(pacienteServicio.obtenerTodos());
    }

    @GetMapping("/{id}")
    public ResponseEntity<PacienteDTO> obtenerPorId(@PathVariable Long id) {
        return ResponseEntity.ok(pacienteServicio.obtenerPorId(id));
    }

    @PostMapping
    public ResponseEntity<PacienteDTO> crear(@Valid @RequestBody PacienteDTO dto) {
        return ResponseEntity.ok(pacienteServicio.crear(dto));
    }

    @PutMapping("/{id}")
    public ResponseEntity<PacienteDTO> modificar(@PathVariable Long id, @Valid @RequestBody PacienteDTO dto) {
        return ResponseEntity.ok(pacienteServicio.modificar(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        pacienteServicio.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}
