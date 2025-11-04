import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // 👉 troque pelo IP da sua máquina, não use "localhost" no navegador
  final String baseUrl = 'http://192.168.0.10:8080/auth';

  Future<String?> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return "Usuário cadastrado com sucesso!";
    } else {
      final error = jsonDecode(response.body);
      return error['message'] ?? "Erro ao registrar usuário.";
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }
}
