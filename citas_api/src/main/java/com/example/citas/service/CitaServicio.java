package com.example.citas.service;

import com.example.citas.dto.CitaDTO;
import com.example.citas.model.Cita;
import com.example.citas.model.Consultorio;
import com.example.citas.model.Medico;
import com.example.citas.model.Paciente;
import com.example.citas.repository.CitaRepository;
import com.example.citas.repository.ConsultorioRepository;
import com.example.citas.repository.MedicoRepository;
import com.example.citas.repository.PacienteRepository;
import org.springframework.stereotype.Service;
import com.example.citas.webconfig.BusinessException;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.util.stream.Collectors;

@Service
public class CitaServicio {
    private static final Logger log = LoggerFactory.getLogger(CitaServicio.class);

    private final CitaRepository citaRepository;
    private final PacienteRepository pacienteRepository;
    private final MedicoRepository medicoRepository;
    private final ConsultorioRepository consultorioRepository;

    public CitaServicio(CitaRepository citaRepository,
                        PacienteRepository pacienteRepository,
                        MedicoRepository medicoRepository,
                        ConsultorioRepository consultorioRepository) {
        this.citaRepository = citaRepository;
        this.pacienteRepository = pacienteRepository;
        this.medicoRepository = medicoRepository;
        this.consultorioRepository = consultorioRepository;
    }

    public List<CitaDTO> obtenerTodas() {
        return citaRepository.findAll()
                .stream()
                .map(this::aDTO)
                .collect(Collectors.toList());
    }

    public CitaDTO obtenerPorId(Long id) {
        Cita c = citaRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Cita no encontrada"));
        return aDTO(c);
    }

    @Transactional
    public CitaDTO crear(CitaDTO dto) {
        // Validaciones de existencia
        Paciente p = pacienteRepository.findById(dto.getPacienteId())
                .orElseThrow(() -> new RuntimeException("Paciente no existe"));
        Medico m = medicoRepository.findById(dto.getMedicoId())
                .orElseThrow(() -> new RuntimeException("Médico no existe"));
        Consultorio cons = consultorioRepository.findById(dto.getConsultorioId())
                .orElseThrow(() -> new RuntimeException("Consultorio no existe"));

    // Regla de negocio: un médico no puede tener dos citas en el mismo horario
    citaRepository.findByMedicoIdAndFechaAndHora(dto.getMedicoId(), dto.getFecha(), dto.getHora())
        .ifPresent(x -> { throw new BusinessException("El médico ya tiene una cita en ese horario"); });

        // Crear y guardar
        Cita c = new Cita();
        c.setPaciente(p);
        c.setMedico(m);
        c.setConsultorio(cons);
        c.setFecha(dto.getFecha());
        c.setHora(dto.getHora());

        citaRepository.save(c);
        return aDTO(c);
    }

    @Transactional
    public CitaDTO modificar(Long id, CitaDTO dto) {
        Cita c = citaRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Cita no encontrada"));
        // Determinar valores objetivo (sin mutar todavía la entidad) para chequear conflicto primero
        Long medicoIdObjetivo = dto.getMedicoId() != null ? dto.getMedicoId() : (c.getMedico() != null ? c.getMedico().getId() : null);
        java.time.LocalDate fechaObjetivo = dto.getFecha() != null ? dto.getFecha() : c.getFecha();
        java.time.LocalTime horaObjetivo = dto.getHora() != null ? dto.getHora() : c.getHora();

        // Si alguno de los tres componentes cambia (o se envía explícitamente) verificamos posible conflicto
        boolean posibleCambioHorario = dto.getMedicoId() != null || dto.getFecha() != null || dto.getHora() != null;
        if (posibleCambioHorario && medicoIdObjetivo != null && fechaObjetivo != null && horaObjetivo != null) {
            citaRepository.findByMedicoIdAndFechaAndHora(medicoIdObjetivo, fechaObjetivo, horaObjetivo)
                    .ifPresent(existing -> {
                        if (!existing.getId().equals(c.getId())) {
                            log.debug("Conflicto detectado antes de actualizar: citaActual={}, citaExistente={} medicoId={} fecha={} hora={}", c.getId(), existing.getId(), medicoIdObjetivo, fechaObjetivo, horaObjetivo);
                            throw new BusinessException("El médico ya tiene una cita en ese horario");
                        }
                    });
        }

        // Ahora aplicar cambios efectivamente (ya se validó conflicto)
        if (dto.getPacienteId() != null && (c.getPaciente() == null || !dto.getPacienteId().equals(c.getPaciente().getId()))) {
            Paciente p = pacienteRepository.findById(dto.getPacienteId())
                    .orElseThrow(() -> new RuntimeException("Paciente no existe"));
            c.setPaciente(p);
        }
        if (dto.getMedicoId() != null && (c.getMedico() == null || !dto.getMedicoId().equals(c.getMedico().getId()))) {
            Medico m = medicoRepository.findById(dto.getMedicoId())
                    .orElseThrow(() -> new RuntimeException("Médico no existe"));
            c.setMedico(m);
        }
        if (dto.getConsultorioId() != null && (c.getConsultorio() == null || !dto.getConsultorioId().equals(c.getConsultorio().getId()))) {
            Consultorio cons = consultorioRepository.findById(dto.getConsultorioId())
                    .orElseThrow(() -> new RuntimeException("Consultorio no existe"));
            c.setConsultorio(cons);
        }
        if (dto.getFecha() != null && (c.getFecha() == null || !dto.getFecha().equals(c.getFecha()))) {
            c.setFecha(dto.getFecha());
        }
        if (dto.getHora() != null && (c.getHora() == null || !dto.getHora().equals(c.getHora()))) {
            c.setHora(dto.getHora());
        }

        citaRepository.save(c);
        return aDTO(c);
    }

    public void eliminar(Long id) {
        citaRepository.deleteById(id);
    }

    private CitaDTO aDTO(Cita c) {
        return new CitaDTO(
                c.getId(),
                c.getPaciente() != null ? c.getPaciente().getId() : null,
                c.getMedico() != null ? c.getMedico().getId() : null,
                c.getConsultorio() != null ? c.getConsultorio().getId() : null,
                c.getFecha(),
                c.getHora()
        );
    }
}
