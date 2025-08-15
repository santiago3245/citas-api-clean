package com.example.citas;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.*;
import org.springframework.test.annotation.DirtiesContext;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_EACH_TEST_METHOD)
class ApiValidationAndCitaIntegrationTest {

    @Autowired
    private TestRestTemplate rest;

    private Long crearPaciente(String nombre, String apellido, LocalDate fechaNacimiento, String email) {
        Map<String,Object> body = new HashMap<>();
        body.put("nombre", nombre);
        body.put("apellido", apellido);
        body.put("fechaNacimiento", fechaNacimiento.toString());
        body.put("email", email);
        ResponseEntity<Map> resp = rest.postForEntity("/pacientes", body, Map.class);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.OK);
        return ((Number)resp.getBody().get("id")).longValue();
    }

    private Long crearMedico(String nombre, String apellido, String especialidad) {
        Map<String,Object> body = new HashMap<>();
        body.put("nombre", nombre);
        body.put("apellido", apellido);
        body.put("especialidad", especialidad);
        ResponseEntity<Map> resp = rest.postForEntity("/medicos", body, Map.class);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.OK);
        return ((Number)resp.getBody().get("id")).longValue();
    }

    private Long crearConsultorio(String numero, int piso) {
        Map<String,Object> body = new HashMap<>();
        body.put("numero", numero);
        body.put("piso", piso);
        ResponseEntity<Map> resp = rest.postForEntity("/consultorios", body, Map.class);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.OK);
        return ((Number)resp.getBody().get("id")).longValue();
    }

    private ResponseEntity<Map> crearCita(Long pacienteId, Long medicoId, Long consultorioId, LocalDate fecha, String horaHHMMSS) {
        Map<String,Object> body = new HashMap<>();
        body.put("pacienteId", pacienteId);
        body.put("medicoId", medicoId);
        body.put("consultorioId", consultorioId);
        body.put("fecha", fecha.toString());
        body.put("hora", horaHHMMSS);
        return rest.postForEntity("/citas", body, Map.class);
    }

    @Test
    @DisplayName("Paciente inválido (email y fecha futura) devuelve 400")
    void pacienteValidacionInvalida() {
        Map<String,Object> body = new HashMap<>();
        body.put("nombre", "Juan");
        body.put("apellido", "Prueba");
        body.put("fechaNacimiento", LocalDate.now().plusDays(1).toString());
        body.put("email", "correo-invalido");
        ResponseEntity<Map> resp = rest.postForEntity("/pacientes", body, Map.class);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
    }

    @Test
    @DisplayName("Consultorio inválido (piso negativo) devuelve 400")
    void consultorioInvalido() {
        Map<String,Object> body = new HashMap<>();
        body.put("numero", "A1");
        body.put("piso", -2);
        ResponseEntity<Map> resp = rest.postForEntity("/consultorios", body, Map.class);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
    }

    @Test
    @DisplayName("Creación de cita y conflicto devuelve 409")
    void citaConflictoMismoMedico() {
        Long p = crearPaciente("Ana","Lopez", LocalDate.of(1990,5,20), "ana@example.com");
        Long m = crearMedico("Carlos","Perez","Cardiologia");
        Long cons = crearConsultorio("101", 1);
        LocalDate fecha = LocalDate.now().plusDays(1);
        ResponseEntity<Map> ok1 = crearCita(p, m, cons, fecha, "10:00:00");
        assertThat(ok1.getStatusCode()).isEqualTo(HttpStatus.OK);
        ResponseEntity<Map> conflicto = crearCita(p, m, cons, fecha, "10:00:00");
        assertThat(conflicto.getStatusCode()).isEqualTo(HttpStatus.CONFLICT);
    }

    @Test
    @DisplayName("Nombre en blanco provoca 400 en Paciente")
    void pacienteNombreEnBlanco() {
        Map<String,Object> body = new HashMap<>();
        body.put("nombre", "   ");
        body.put("apellido", "Test");
        body.put("fechaNacimiento", LocalDate.of(1999,1,1).toString());
        body.put("email", "a@a.com");
        ResponseEntity<Map> resp = rest.postForEntity("/pacientes", body, Map.class);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
    }

    @Test
    @DisplayName("Horas límite 00:00:00 y 23:59:59 aceptadas")
    void citaHorasLimite() {
        Long p = crearPaciente("Beta","Uno", LocalDate.of(1990,1,1), "b1@example.com");
        Long m = crearMedico("Doc","House","Diagnostico");
        Long cons = crearConsultorio("201", 2);
        LocalDate fecha = LocalDate.now().plusDays(2);
        ResponseEntity<Map> h1 = crearCita(p,m,cons,fecha,"00:00:00");
        assertThat(h1.getStatusCode()).isEqualTo(HttpStatus.OK);
        ResponseEntity<Map> h2 = crearCita(p,m,cons,fecha,"23:59:59");
        assertThat(h2.getStatusCode()).isEqualTo(HttpStatus.OK);
    }

    @Test
    @DisplayName("Modificar cita genera conflicto 409 al cambiar a horario ocupado")
    void modificarCitaConflicto() {
        Long p = crearPaciente("Carla","Mendez", LocalDate.of(1992,2,2), "carla@example.com");
        Long m = crearMedico("Luis","Torres","Oncologia");
        Long cons = crearConsultorio("303", 3);
        LocalDate fecha = LocalDate.now().plusDays(3);
        ResponseEntity<Map> cita1 = crearCita(p,m,cons,fecha,"08:00:00");
        ResponseEntity<Map> cita2 = crearCita(p,m,cons,fecha,"09:00:00");
        assertThat(cita1.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(cita2.getStatusCode()).isEqualTo(HttpStatus.OK);
        Long idCita2 = ((Number)cita2.getBody().get("id")).longValue();

        Map<String,Object> update = new HashMap<>();
        update.put("pacienteId", p);
        update.put("medicoId", m);
        update.put("consultorioId", cons);
        update.put("fecha", fecha.toString());
        update.put("hora", "08:00:00");

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String,Object>> entity = new HttpEntity<>(update, headers);
        ResponseEntity<Map> resp = rest.exchange("/citas/"+idCita2, HttpMethod.PUT, entity, Map.class);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.CONFLICT);
    }

    @Test
    @DisplayName("GET de recurso inexistente devuelve 404")
    void getNoExiste() {
        ResponseEntity<Map> resp = rest.getForEntity("/pacientes/999999", Map.class);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
    }

    @Test
    @DisplayName("Cita con fecha pasada rechazada (400)")
    void citaFechaPasada() {
        Long p = crearPaciente("Luis","Ramos", LocalDate.of(1985,3,10), "luis@example.com");
        Long m = crearMedico("Maria","Diaz","Dermatologia");
        Long cons = crearConsultorio("202", 2);
        LocalDate pasada = LocalDate.now().minusDays(1);
        ResponseEntity<Map> resp = crearCita(p, m, cons, pasada, "09:30:00");
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
    }
}
