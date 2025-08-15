package com.example.citas.service;

import com.example.citas.dto.ConsultorioDTO;
import com.example.citas.model.Consultorio;
import com.example.citas.repository.ConsultorioRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ConsultorioServicio {

    private final ConsultorioRepository consultorioRepository;

    public ConsultorioServicio(ConsultorioRepository consultorioRepository) {
        this.consultorioRepository = consultorioRepository;
    }

    public List<ConsultorioDTO> obtenerTodos() {
        return consultorioRepository.findAll()
                .stream()
                .map(this::aDTO)
                .collect(Collectors.toList());
    }

    public ConsultorioDTO obtenerPorId(Long id) {
        Consultorio c = consultorioRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Consultorio no encontrado"));
        return aDTO(c);
    }

    public ConsultorioDTO crear(ConsultorioDTO dto) {
        Consultorio c = new Consultorio();
        c.setNumero(dto.getNumero());
        c.setPiso(dto.getPiso());
        consultorioRepository.save(c);
        return obtenerPorId(c.getId());
    }

    public ConsultorioDTO modificar(Long id, ConsultorioDTO dto) {
        Consultorio c = consultorioRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Consultorio no encontrado"));
        c.setNumero(dto.getNumero());
        c.setPiso(dto.getPiso());
        consultorioRepository.save(c);
        return aDTO(c);
    }

    public void eliminar(Long id) {
        consultorioRepository.deleteById(id);
    }

    private ConsultorioDTO aDTO(Consultorio c) {
        return new ConsultorioDTO(
                c.getId(),
                c.getNumero(),
                c.getPiso()
        );
    }
}
