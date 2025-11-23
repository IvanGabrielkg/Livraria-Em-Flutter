import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl; // normalmente termina com /auth

  AuthService({String? baseUrl})
      : baseUrl = baseUrl ?? _defaultBaseUrl();

  static String _defaultBaseUrl() {
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080/auth';
      return 'http://localhost:8080/auth';
    } catch (_) {
      return 'http://localhost:8080/auth';
    }
  }

  // Deriva a raiz sem /auth para acessar /user ou outros endpoints fora do módulo auth.
  String get _rootBaseUrl =>
      baseUrl.replaceFirst(RegExp(r'/auth/?$'), '');

  Map<String, String> get _jsonHeaders => const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<String?> register(String name, String email, String password) async {
    final uri = Uri.parse('$baseUrl/register');
    try {
      final response = await http
          .post(uri,
          headers: _jsonHeaders,
          body: jsonEncode({'name': name, 'email': email, 'password': password}))
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return 'Usuário cadastrado com sucesso!';
      }
      return _parseErrorMessage(response.body,
          fallback: 'Erro ao registrar usuário. Código: ${response.statusCode}');
    } catch (e) {
      print('[AuthService.register] exception: $e');
      return 'Falha de conexão. Tente novamente.';
    }
  }

  Future<String?> login(String email, String password) async {
    final uri = Uri.parse('$baseUrl/login');
    try {
      final response = await http
          .post(uri,
          headers: _jsonHeaders,
          body: jsonEncode({'email': email, 'password': password}))
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final token = json['token'] as String?;
        if (token != null && token.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', token);
          print('[AuthService.login] token salvo.');
          return token;
        }
      } else {
        print('[AuthService.login] status=${response.statusCode} body=${response.body}');
      }
      return null;
    } catch (e) {
      print('[AuthService.login] exception: $e');
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    print('[AuthService.logout] token removido.');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<bool> isLoggedIn() async {
    final t = await getToken();
    return t != null && t.isNotEmpty;
  }

  /// Tenta múltiplas rotas para obter perfil:
  /// 1. /auth/me
  /// 2. /auth/user (caso você crie)
  /// 3. /user (fora do /auth)
  /// Aceita JSON {"name": "...", "email": "..."} ou string simples (nome).
  Future<Map<String, dynamic>?> fetchProfile() async {
    final token = await getToken();
    if (token == null) return null;

    Future<Map<String, dynamic>?> tryEndpoint(String url) async {
      final uri = Uri.parse(url);
      try {
        final response = await http
            .get(uri, headers: {
          ..._jsonHeaders,
          'Authorization': 'Bearer $token',
        })
            .timeout(const Duration(seconds: 10));

        print('[AuthService.fetchProfile] GET $url status=${response.statusCode}');

        if (response.statusCode == 200) {
          final body = response.body.trim();
          if (body.isEmpty) return null;
          if (body.startsWith('{') && body.endsWith('}')) {
            final decoded = jsonDecode(body);
            if (decoded is Map<String, dynamic>) return decoded;
          }
          // caso retorne apenas o nome como texto
          return {'name': body};
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          // bloqueado ou não autorizado — retorna null sem lançar
          return null;
        }
      } catch (e) {
        print('[AuthService.fetchProfile] exception em $url: $e');
      }
      return null;
    }

    // Tenta em ordem
    return await tryEndpoint('$baseUrl/me') ??
        await tryEndpoint('$baseUrl/user') ?? // caso mapeie dentro de /auth
        await tryEndpoint('$_rootBaseUrl/user');
  }

  /// Endpoint direto /user (apenas se quiser chamar explicitamente)
  Future<Map<String, dynamic>?> fetchUser() async {
    final token = await getToken();
    if (token == null) return null;
    final uri = Uri.parse('$_rootBaseUrl/user');
    try {
      final response = await http
          .get(uri, headers: {
        ..._jsonHeaders,
        'Authorization': 'Bearer $token',
      })
          .timeout(const Duration(seconds: 10));

      print('[AuthService.fetchUser] status=${response.statusCode} body=${response.body}');

      if (response.statusCode == 200) {
        final body = response.body.trim();
        if (body.startsWith('{') && body.endsWith('}')) {
          final decoded = jsonDecode(body);
          if (decoded is Map<String, dynamic>) return decoded;
        }
        return {'name': body};
      }
      return null;
    } catch (e) {
      print('[AuthService.fetchUser] exception: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> decodeLocalTokenClaims() async {
    final token = await getToken();
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payloadSegment = _normalizeBase64(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payloadSegment));
      final map = jsonDecode(decoded);
      return map is Map<String, dynamic> ? map : null;
    } catch (e) {
      print('[AuthService.decodeLocalTokenClaims] exception: $e');
      return null;
    }
  }

  String _parseErrorMessage(String body, {required String fallback}) {
    try {
      final json = jsonDecode(body);
      if (json is Map) {
        for (final key in ['message', 'error', 'detail']) {
          final val = json[key];
          if (val is String && val.trim().isNotEmpty) return val;
        }
      }
    } catch (_) {}
    return fallback;
  }

  String _normalizeBase64(String input) {
    final pad = (4 - input.length % 4) % 4;
    return input + ('=' * pad);
  }
}
