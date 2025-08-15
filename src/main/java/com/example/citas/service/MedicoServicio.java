package com.example.citas.service;

import com.example.citas.dto.MedicoDTO;
import com.example.citas.model.Medico;
import com.example.citas.repository.MedicoRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class MedicoServicio {

    private final MedicoRepository medicoRepository;

    public MedicoServicio(MedicoRepository medicoRepository) {
        this.medicoRepository = medicoRepository;
    }

    public List<MedicoDTO> obtenerTodos() {
        return medicoRepository.findAll()
                .stream()
                .map(this::aDTO)
                .collect(Collectors.toList());
    }

    public MedicoDTO obtenerPorId(Long id) {
        Medico m = medicoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Médico no encontrado"));
        return aDTO(m);
    }

    public MedicoDTO crear(MedicoDTO dto) {
        Medico m = new Medico();
        m.setNombre(dto.getNombre());
        m.setApellido(dto.getApellido());
        m.setEspecialidad(dto.getEspecialidad());
        medicoRepository.save(m);
        return obtenerPorId(m.getId());
    }

    public MedicoDTO modificar(Long id, MedicoDTO dto) {
        Medico m = medicoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Médico no encontrado"));
        m.setNombre(dto.getNombre());
        m.setApellido(dto.getApellido());
        m.setEspecialidad(dto.getEspecialidad());
        medicoRepository.save(m);
        return aDTO(m);
    }

    public void eliminar(Long id) {
        medicoRepository.deleteById(id);
    }

    private MedicoDTO aDTO(Medico m) {
        return new MedicoDTO(
                m.getId(),
                m.getNombre(),
                m.getApellido(),
                m.getEspecialidad()
        );
    }
}
