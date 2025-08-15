package com.example.citas.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.FutureOrPresent;
import java.time.LocalDate;
import java.time.LocalTime;

public class CitaDTO {
    private Long id;
    @NotNull private Long pacienteId;
    @NotNull private Long medicoId;
    @NotNull private Long consultorioId;
    @NotNull @FutureOrPresent(message = "La fecha debe ser hoy o futura")
    private LocalDate fecha;
    @NotNull
    private LocalTime hora;

    public CitaDTO(Long id, Long pacienteId, Long medicoId, Long consultorioId, LocalDate fecha, LocalTime hora) {
        this.id = id;
        this.pacienteId = pacienteId;
        this.medicoId = medicoId;
        this.consultorioId = consultorioId;
        this.fecha = fecha;
        this.hora = hora;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getPacienteId() { return pacienteId; }
    public void setPacienteId(Long pacienteId) { this.pacienteId = pacienteId; }
    public Long getMedicoId() { return medicoId; }
    public void setMedicoId(Long medicoId) { this.medicoId = medicoId; }
    public Long getConsultorioId() { return consultorioId; }
    public void setConsultorioId(Long consultorioId) { this.consultorioId = consultorioId; }
    public LocalDate getFecha() { return fecha; }
    public void setFecha(LocalDate fecha) { this.fecha = fecha; }
    public LocalTime getHora() { return hora; }
    public void setHora(LocalTime hora) { this.hora = hora; }
}
