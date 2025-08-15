class ApiConfig {
  static const String baseUrl = 'http://localhost:8080'; // Tu API Spring Boot
  static const String loginEndpoint = '/auth/login';
  static const String citasEndpoint = '/citas';
  static const String pacientesEndpoint = '/pacientes';
  static const String medicosEndpoint = '/medicos';

  // Headers comunes
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}