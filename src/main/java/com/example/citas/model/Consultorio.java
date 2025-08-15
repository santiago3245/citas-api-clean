package com.example.citas.model;

import jakarta.persistence.*;

@Entity
public class Consultorio {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true)
    private String numero;

    private Integer piso;

    // Getters y setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNumero() { return numero; }
    public void setNumero(String numero) { this.numero = numero; }

    public Integer getPiso() { return piso; }
    public void setPiso(Integer piso) { this.piso = piso; }
}
