package com.example.citas.dto;

import java.time.LocalDate;
import jakarta.validation.constraints.*;

public class PacienteDTO {
    private Long id;
    @NotBlank
    private String nombre;
    @NotBlank
    private String apellido;
    @Past(message = "La fecha de nacimiento debe ser pasada")
    private LocalDate fechaNacimiento;
    @NotBlank @Email
    private String email;

    public PacienteDTO(Long id, String nombre, String apellido, LocalDate fechaNacimiento, String email) {
        this.id = id;
        this.nombre = nombre;
        this.apellido = apellido;
        this.fechaNacimiento = fechaNacimiento;
        this.email = email;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getApellido() { return apellido; }
    public void setApellido(String apellido) { this.apellido = apellido; }

    public LocalDate getFechaNacimiento() { return fechaNacimiento; }
    public void setFechaNacimiento(LocalDate fechaNacimiento) { this.fechaNacimiento = fechaNacimiento; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
}
