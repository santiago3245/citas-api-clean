import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';
  String? _token;

  void setToken(String token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<dynamic> _handle(http.Response r) async {
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('Error ${r.statusCode}: ${r.body}');
    }
    if (r.body.isEmpty) return null;
    return json.decode(r.body);
  }

  Future<dynamic> get(String endpoint) async =>
      _handle(await http.get(Uri.parse('$baseUrl$endpoint'), headers: _headers));

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async =>
      _handle(await http.post(Uri.parse('$baseUrl$endpoint'), headers: _headers, body: json.encode(body)));

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async =>
      _handle(await http.put(Uri.parse('$baseUrl$endpoint'), headers: _headers, body: json.encode(body)));

  Future<void> delete(String endpoint) async {
    await _handle(await http.delete(Uri.parse('$baseUrl$endpoint'), headers: _headers));
  }
}