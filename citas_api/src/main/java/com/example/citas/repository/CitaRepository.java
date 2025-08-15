package com.example.citas.repository;

import com.example.citas.model.Cita;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface CitaRepository extends JpaRepository<Cita, Long> {

    // Buscar citas por fecha
    List<Cita> findByFecha(LocalDate fecha);

    // Buscar citas por médico en un día
    List<Cita> findByMedicoIdAndFecha(Long medicoId, LocalDate fecha);

    // Verificar si un médico ya tiene cita en esa fecha y hora
    Optional<Cita> findByMedicoIdAndFechaAndHora(Long medicoId, LocalDate fecha, LocalTime hora);

    // Verificar existencia de otra cita (id distinto) para conflicto en modificación
    boolean existsByMedicoIdAndFechaAndHoraAndIdNot(Long medicoId, LocalDate fecha, LocalTime hora, Long id);

    // Buscar citas por paciente
    List<Cita> findByPacienteId(Long pacienteId);
}
