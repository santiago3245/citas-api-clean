package com.example.citas.controller;

import com.example.citas.dto.CitaDTO;
import com.example.citas.service.CitaServicio;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/citas")
public class CitaController {

    private final CitaServicio citaServicio;

    public CitaController(CitaServicio citaServicio) {
        this.citaServicio = citaServicio;
    }

    @GetMapping
    public ResponseEntity<List<CitaDTO>> obtenerTodas() {
        return ResponseEntity.ok(citaServicio.obtenerTodas());
    }

    @GetMapping("/{id}")
    public ResponseEntity<CitaDTO> obtenerPorId(@PathVariable Long id) {
        return ResponseEntity.ok(citaServicio.obtenerPorId(id));
    }

    @PostMapping
    public ResponseEntity<CitaDTO> crear(@Valid @RequestBody CitaDTO dto) {
        // El servicio debe validar solapamiento (mismo médico, fecha y hora)
        return ResponseEntity.ok(citaServicio.crear(dto));
    }

    @PutMapping("/{id}")
    public ResponseEntity<CitaDTO> modificar(@PathVariable Long id, @Valid @RequestBody CitaDTO dto) {
        return ResponseEntity.ok(citaServicio.modificar(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        citaServicio.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}
