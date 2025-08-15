package com.example.citas.repository;

import com.example.citas.model.Paciente;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PacienteRepository extends JpaRepository<Paciente, Long> {

    // Buscar por nombre exacto
    List<Paciente> findByNombre(String nombre);

    // Buscar por email exacto
    List<Paciente> findByEmail(String email);

    // Buscar por parte del nombre (insensible a mayúsculas)
    List<Paciente> findByNombreContainingIgnoreCase(String parteDelNombre);

    // Buscar por nombre y apellido
    List<Paciente> findByNombreAndApellido(String nombre, String apellido);
}
