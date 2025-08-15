package com.example.citas.service;

import com.example.citas.dto.PacienteDTO;
import com.example.citas.model.Paciente;
import com.example.citas.repository.PacienteRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class PacienteServicio {

    private final PacienteRepository pacienteRepository;

    public PacienteServicio(PacienteRepository pacienteRepository) {
        this.pacienteRepository = pacienteRepository;
    }

    public List<PacienteDTO> obtenerTodos() {
        return pacienteRepository.findAll()
                .stream()
                .map(this::aDTO)
                .collect(Collectors.toList());
    }

    public PacienteDTO obtenerPorId(Long id) {
        Paciente paciente = pacienteRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Paciente no encontrado"));
        return aDTO(paciente);
    }

    public PacienteDTO crear(PacienteDTO dto) {
        Paciente p = new Paciente();
        p.setNombre(dto.getNombre());
        p.setApellido(dto.getApellido());
        p.setFechaNacimiento(dto.getFechaNacimiento());
        p.setEmail(dto.getEmail());
        pacienteRepository.save(p);
        return obtenerPorId(p.getId());
    }

    public PacienteDTO modificar(Long id, PacienteDTO dto) {
        Paciente p = pacienteRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Paciente no encontrado"));
        p.setNombre(dto.getNombre());
        p.setApellido(dto.getApellido());
        p.setFechaNacimiento(dto.getFechaNacimiento());
        p.setEmail(dto.getEmail());
        pacienteRepository.save(p);
        return aDTO(p);
    }

    public void eliminar(Long id) {
        pacienteRepository.deleteById(id);
    }

    private PacienteDTO aDTO(Paciente p) {
        return new PacienteDTO(
                p.getId(),
                p.getNombre(),
                p.getApellido(),
                p.getFechaNacimiento(),
                p.getEmail()
        );
    }
}
