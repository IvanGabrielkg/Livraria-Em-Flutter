import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  /// Base URL principal do módulo de auth.
  /// Ajuste conforme seu ambiente. Se não passar nada no construtor, tenta deduzir.
  final String baseUrl;

  AuthService({String? baseUrl})
      : baseUrl = baseUrl ?? _defaultBaseUrl();

  /// Escolhe um baseUrl padrão conforme plataforma:
  /// - Android emulator: 10.0.2.2
  /// - iOS simulator / Web local: localhost
  /// Ajuste para o IP da máquina na rede se estiver testando em dispositivo físico.
  static String _defaultBaseUrl() {
    try {
      if (Platform.isAndroid) {
        // Para emulador Android acessar o host local
        return 'http://10.0.2.2:8080/auth';
      }
      // iOS simulator, desktop, web (quando rodando via `flutter run -d chrome`)
      return 'http://localhost:8080/auth';
    } catch (_) {
      // Se Platform não disponível (ex: compilação web sem dart:io)
      return 'http://localhost:8080/auth';
    }
  }

  Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Registra usuário utilizando campo 'name' (necessário para evitar ConstraintViolation).
  Future<String?> register(String name, String email, String password) async {
    final uri = Uri.parse('$baseUrl/register');

    try {
      final response = await http
          .post(
        uri,
        headers: _jsonHeaders,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      )
          .timeout(const Duration(seconds: 12));

      final status = response.statusCode;
      final body = response.body;

      print('[AuthService.register] status=$status body=$body');

      if (status == 200 || status == 201) {
        return 'Usuário cadastrado com sucesso!';
      } else {
        return _parseErrorMessage(body, fallback: 'Erro ao registrar usuário. Código: $status');
      }
    } catch (e) {
      print('[AuthService.register] exception: $e');
      return 'Falha de conexão. Tente novamente.';
    }
  }

  /// Login: retorna token (JWT) ou null.
  Future<String?> login(String email, String password) async {
    final uri = Uri.parse('$baseUrl/login');

    try {
      final response = await http
          .post(
        uri,
        headers: _jsonHeaders,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      )
          .timeout(const Duration(seconds: 12));

      final status = response.statusCode;
      final body = response.body;

      print('[AuthService.login] status=$status body=$body');

      if (status == 200) {
        final json = jsonDecode(body);
        final token = json['token'] as String?;
        if (token != null && token.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', token);
          print('[AuthService.login] token salvo.');
          return token;
        } else {
          print('[AuthService.login] resposta sem token.');
        }
      } else {
        print('[AuthService.login] falha status=$status');
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
    // Se tiver refresh token, remova também.
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

  /// Tenta buscar dados do usuário logado. Ajuste se seu backend usar rota diferente (/api/auth/me).
  Future<Map<String, dynamic>?> fetchProfile() async {
    final token = await getToken();
    if (token == null) return null;

    final uri = Uri.parse('$baseUrl/me');

    try {
      final response = await http
          .get(
        uri,
        headers: {
          ..._jsonHeaders,
          'Authorization': 'Bearer $token',
        },
      )
          .timeout(const Duration(seconds: 10));

      final status = response.statusCode;
      final body = response.body;

      print('[AuthService.fetchProfile] status=$status body=$body');

      if (status == 200) {
        final json = jsonDecode(body);
        if (json is Map<String, dynamic>) return json;
      } else {
        print('[AuthService.fetchProfile] erro status=$status');
      }
      return null;
    } catch (e) {
      print('[AuthService.fetchProfile] exception: $e');
      return null;
    }
  }

  /// Decodifica localmente o payload do JWT (não valida assinatura).
  /// Útil como fallback se /me não existir.
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

  /// Ponto futuro para refresh token (se o backend expuser /auth/refresh).
  /// Exemplo (placeholder):
  /*
  Future<String?> refreshToken() async {
    final refresh = await _getRefreshToken();
    if (refresh == null) return null;

    final uri = Uri.parse('$baseUrl/refresh');
    try {
      final response = await http.post(
        uri,
        headers: _jsonHeaders,
        body: jsonEncode({'refreshToken': refresh}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final newToken = json['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', newToken);
        return newToken;
      }
    } catch (e) {
      print('[AuthService.refreshToken] exception: $e');
    }
    return null;
  }
  */

  // ----------------- Métodos privados utilitários -----------------

  String _parseErrorMessage(String body, {required String fallback}) {
    try {
      final json = jsonDecode(body);
      if (json is Map) {
        // tenta várias chaves possíveis
        for (final key in ['message', 'error', 'detail']) {
          final val = json[key];
          if (val is String && val.trim().isNotEmpty) {
            return val;
          }
        }
      }
    } catch (_) {
      // ignore parse errors
    }
    return fallback;
  }

  String _normalizeBase64(String input) {
    // Corrige padding faltante
    final pad = (4 - input.length % 4) % 4;
    return input + ('=' * pad);
  }
}