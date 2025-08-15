package com.example.citas.repository;

import com.example.citas.model.Consultorio;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ConsultorioRepository extends JpaRepository<Consultorio, Long> {

    // Buscar por número exacto
    List<Consultorio> findByNumero(String numero);

    // Buscar por piso
    List<Consultorio> findByPiso(Integer piso);
}
