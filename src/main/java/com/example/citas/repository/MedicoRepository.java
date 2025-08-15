package com.example.citas.repository;

import com.example.citas.model.Medico;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MedicoRepository extends JpaRepository<Medico, Long> {

    // Buscar por especialidad
    List<Medico> findByEspecialidad(String especialidad);

    // Buscar por nombre parcial
    List<Medico> findByNombreContainingIgnoreCase(String parteDelNombre);

    // Buscar por nombre y especialidad
    List<Medico> findByNombreAndEspecialidad(String nombre, String especialidad);
}
