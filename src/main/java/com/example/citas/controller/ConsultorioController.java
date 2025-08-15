package com.example.citas.controller;

import com.example.citas.dto.ConsultorioDTO;
import com.example.citas.service.ConsultorioServicio;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/consultorios")
public class ConsultorioController {

    private final ConsultorioServicio consultorioServicio;

    public ConsultorioController(ConsultorioServicio consultorioServicio) {
        this.consultorioServicio = consultorioServicio;
    }

    @GetMapping
    public ResponseEntity<List<ConsultorioDTO>> obtenerTodos() {
        return ResponseEntity.ok(consultorioServicio.obtenerTodos());
    }

    @GetMapping("/{id}")
    public ResponseEntity<ConsultorioDTO> obtenerPorId(@PathVariable Long id) {
        return ResponseEntity.ok(consultorioServicio.obtenerPorId(id));
    }

    @PostMapping
    public ResponseEntity<ConsultorioDTO> crear(@Valid @RequestBody ConsultorioDTO dto) {
        return ResponseEntity.ok(consultorioServicio.crear(dto));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ConsultorioDTO> modificar(@PathVariable Long id, @Valid @RequestBody ConsultorioDTO dto) {
        return ResponseEntity.ok(consultorioServicio.modificar(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        consultorioServicio.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}
